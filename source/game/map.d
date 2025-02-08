module game.map;

public import utility.collision_functions : CollisionAxis;
import fast_noise;
import game.biome_database;
import game.block_database;
import graphics.camera_handler;
import graphics.render;
import graphics.texture_handler;
import math.vec2d;
import std.algorithm.comparison;
import std.conv;
import std.math.algebraic;
import std.math.rounding;
import std.random;
import std.stdio;
import utility.window;

immutable public int CHUNK_WIDTH = 32;
immutable public int CHUNK_HEIGHT = 256;

struct ChunkData {
    int blockID = 0;
}

final class Chunk {
    ChunkData[CHUNK_HEIGHT][CHUNK_WIDTH] data;
}

static final const class Map {
static:
private:

    Chunk[int] database;
    FNLState noise;
    Vec2d[] debugDrawPoints = [];

public: //* BEGIN PUBLIC API.

    void initialize() {
        noise.seed = 1_010_010;
    }

    void draw() {

        //? Screen draws, bottom left to top right.
        int windowWidth = Window.getWidth();
        int windowHeight = Window.getHeight();

        Vec2d bottomLeft = CameraHandler.screenToWorld(0, 0);
        Vec2d topRight = CameraHandler.screenToWorld(windowWidth, windowHeight);

        int minX = cast(int) floor(bottomLeft.x);
        int minY = cast(int) floor(bottomLeft.y);

        int maxX = cast(int) floor(topRight.x);
        int maxY = cast(int) floor(topRight.y);

        // Player has been exploded out of the world.
        if (minY > CHUNK_HEIGHT) {
            writeln("exploded");
            return;
        }
        // Player has fallen out of the world.
        if (maxY < 0) {
            writeln("fallen");
            return;
        }

        minY = clamp(minY, 0, CHUNK_HEIGHT);
        maxY = clamp(maxY, 0, CHUNK_HEIGHT);

        // todo: cache the chunk. Maybe.

        foreach (x; minX .. maxX + 1) {

            foreach (y; minY .. maxY + 1) {

                Vec2d position = Vec2d(x, y);

                ChunkData thisData = getBlockAtWorldPosition(position);

                position.y += 1;

                if (thisData.blockID == 0) {
                    Render.rectangleLines(position, Vec2d(1, 1), Colors.WHITE);
                    continue;
                }

                // +1 on Y because it's drawn with the origin at the top left.

                // Render.rectangle(position, Vec2d(1, 1), Colors.ORANGE);

                BlockDefinitionResult thisBlockResult = BlockDatabase.getBlockByID(
                    thisData.blockID);

                if (!thisBlockResult.exists) {
                    TextureHandler.drawTexture("unknown.png", position, Vec2d(16, 16), Vec2d(1, 1));
                } else {
                    TextureHandler.drawTexture(thisBlockResult.definition.texture, position, Vec2d(16, 16), Vec2d(
                            1, 1));
                }

                Render.rectangleLines(position, Vec2d(1, 1), Colors.WHITE);

            }
        }
    }

    void drawDebugPoints() {
        foreach (point; debugDrawPoints) {
            Render.circle(point, 0.1, Colors.ORANGE);
        }
    }

    double getTop(double xPosition) {
        int chunkID = calculateChunkAtWorldPosition(xPosition);
        int xPosInChunk = getXInChunk(xPosition);

        if (chunkID !in database) {
            return 0;
        }

        Chunk thisChunk = database[chunkID];

        foreach_reverse (y; 0 .. CHUNK_HEIGHT) {
            if (thisChunk.data[xPosInChunk][y].blockID != 0) {
                return y + 1;
            }
        }
        return 0;
    }

    int calculateChunkAtWorldPosition(double x) {
        return cast(int) floor(x / CHUNK_WIDTH);
    }

    int getXInChunk(double x) {
        int result = cast(int) floor(x % CHUNK_WIDTH);
        // Account for negatives.
        if (result < 0) {
            result += CHUNK_WIDTH;
        }
        return result;
    }

    ChunkData getBlockAtWorldPosition(Vec2d position) {
        int chunkID = calculateChunkAtWorldPosition(position.x);

        if (chunkID !in database) {
            return ChunkData();
        }

        int xPosInChunk = getXInChunk(position.x);

        int yPosInChunk = cast(int) floor(position.y);
        // Out of bounds.
        if (yPosInChunk < 0 || yPosInChunk >= CHUNK_HEIGHT) {
            return ChunkData();
        }

        return database[chunkID].data[xPosInChunk][yPosInChunk];
    }

    void worldLoad(int currentPlayerChunk) {
        foreach (i; currentPlayerChunk - 1 .. currentPlayerChunk + 2) {
            writeln("loading chunk ", i);
            loadChunk(i);
        }

        // This can get very laggy if old chunks are not unloaded. :)
        unloadOldChunks(currentPlayerChunk);
    }

    void collideEntityToWorld(ref Vec2d entityPosition, Vec2d entitySize, ref Vec2d entityVelocity,
        CollisionAxis axis) {

        if (axis == axis.X) {
            collisionX(entityPosition, entitySize, entityVelocity);
        } else {
            collisionY(entityPosition, entitySize, entityVelocity);
        }

    }

private: //* BEGIN INTERNAL API.

    void collisionX(ref Vec2d entityPosition, Vec2d entitySize, ref Vec2d entityVelocity) {

        int currentChunkID = int.min;
        int oldX = int.min;
        int oldY = int.min;
        int currentX = int.min;
        int currentY = int.min;
        Chunk currentChunk = null;

        debugDrawPoints = [];

        foreach (double xOnRect; 0 .. ceil(entitySize.x) + 1) {
            double thisXPoint = (xOnRect > entitySize.x) ? entitySize.x : xOnRect;
            thisXPoint += entityPosition.x - (entitySize.x * 0.5);
            oldX = currentX;
            currentX = cast(int) floor(thisXPoint);

            if (oldX == currentX) {
                // writeln("skip X ", currentY);
                continue;
            }

            foreach (double yOnRect; 0 .. ceil(entitySize.y) + 1) {
                double thisYPoint = (yOnRect > entitySize.y) ? entitySize.y : yOnRect;
                thisYPoint += entityPosition.y;

                oldY = currentY;
                currentY = cast(int) floor(thisYPoint);

                if (currentY == oldY) {
                    // writeln("skip Y ", currentY);
                    continue;
                }

                debugDrawPoints ~= Vec2d(thisXPoint, thisYPoint);

                ChunkData data = getBlockAtWorldPosition(Vec2d(currentX, currentY));

                // todo: if solid collide.

            }

        }

    }

    void collisionY(ref Vec2d entityPosition, Vec2d entitySize, ref Vec2d entityVelocity) {

    }

    void unloadOldChunks(int currentPlayerChunk) {

        // todo: save the chunks to mongoDB.

        int[] keys = [] ~ database.keys;

        foreach (int key; keys) {
            if (abs(key - currentPlayerChunk) > 1) {
                database.remove(key);
                // todo: save the chunks to mongoDB.
                // writeln("deleted: " ~ to!string(key));
            }
        }
    }

    void loadChunk(int chunkPosition) {
        // Already loaded.
        if (chunkPosition in database) {
            return;
        }
        // todo: try to read from mongoDB.
        Chunk newChunk = new Chunk();
        generateChunkData(chunkPosition, newChunk);
        database[chunkPosition] = newChunk;
    }

    void generateChunkData(int chunkPosition, ref Chunk thisChunk) {

        // todo: the chunk should have a biome.
        BiomeDefinitionResult biomeResult = BiomeDatabase.getBiomeByID(0);
        if (!biomeResult.exists) {
            import std.conv;

            throw new Error("Attempted to get biome " ~ to!string(0) ~ " which does not exist");
        }

        immutable double baseHeight = 160;

        immutable int basePositionX = chunkPosition * CHUNK_WIDTH;

        BlockDefinitionResult bedrockResult = BlockDatabase.getBlockByName("bedrock");
        if (!bedrockResult.exists) {
            throw new Error("Please do not remove bedrock from the engine.");
        }

        BlockDefinitionResult stoneResult = BlockDatabase.getBlockByID(
            biomeResult.definition.stoneLayerID);
        if (!stoneResult.exists) {
            throw new Error("Stone does not exist for biome " ~ biomeResult.definition.name);
        }

        BlockDefinitionResult dirtResult = BlockDatabase.getBlockByID(
            biomeResult.definition.dirtLayerID);
        if (!dirtResult.exists) {
            throw new Error("Dirt does not exist for biome " ~ biomeResult.definition.name);
        }

        BlockDefinitionResult grassResult = BlockDatabase.getBlockByID(
            biomeResult.definition.grassLayerID);
        if (!grassResult.exists) {
            throw new Error("Grass does not exist for biome " ~ biomeResult.definition.name);
        }

        foreach (x; 0 .. CHUNK_WIDTH) {

            immutable double selectedNoise = fnlGetNoise2D(&noise, x + basePositionX, 0);

            immutable double noiseScale = 20;

            immutable int selectedHeight = cast(int) floor(
                baseHeight + (selectedNoise * noiseScale));

            immutable int grassLayer = selectedHeight;
            immutable int dirtLayer = selectedHeight - 3;

            immutable double bedRockNoise = fnlGetNoise2D(&noise, (x + basePositionX) * 12, 0) * 2;
            immutable int bedRockSelectedHeight = cast(int) round(abs(bedRockNoise));

            yStack: foreach (y; 0 .. CHUNK_HEIGHT) {

                if (y > selectedHeight) {
                    break yStack;
                }

                if (y == 0) {
                    thisChunk.data[x][y].blockID = bedrockResult.definition.id;
                } else if (y <= 2) {
                    if (y <= bedRockSelectedHeight) {
                        thisChunk.data[x][y].blockID = bedrockResult.definition.id;
                    } else {
                        thisChunk.data[x][y].blockID = stoneResult.definition.id;
                    }
                } else if (y < dirtLayer) {
                    thisChunk.data[x][y].blockID = stoneResult.definition.id;
                } else if (y < grassLayer) {
                    thisChunk.data[x][y].blockID = dirtResult.definition.id;
                } else if (y == grassLayer) {
                    thisChunk.data[x][y].blockID = grassResult.definition.id;
                }
            }
        }
    }

}
