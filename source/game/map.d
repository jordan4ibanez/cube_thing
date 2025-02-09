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
    double gravity = 20.0;

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

    double getGravity() {
        return gravity;
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

    void setBlockAtWorldPositionByID(Vec2d position, int id) {
        if (!BlockDatabase.hasBlockID(id)) {
            throw new Error("Cannot set to block ID " ~ to!string(id) ~ ", ID does not exist.");
        }

        int chunkID = calculateChunkAtWorldPosition(position.x);

        if (chunkID !in database) {
            // todo: maybe unload the chunk after?
            loadChunk(chunkID);
        }

        int xPosInChunk = getXInChunk(position.x);

        int yPosInChunk = cast(int) floor(position.y);

        // Out of bounds.
        if (yPosInChunk < 0 || yPosInChunk >= CHUNK_HEIGHT) {
            writeln("WARNING! trying to write out of bounds! " ~ to!string(yPosInChunk));
        }

        database[chunkID].data[xPosInChunk][yPosInChunk].blockID = id;
    }

    void setBlockAtWorldPositionByName(Vec2d position, string name) {

        int chunkID = calculateChunkAtWorldPosition(position.x);

        if (chunkID !in database) {
            // todo: maybe unload the chunk after?
            loadChunk(chunkID);
        }

        int xPosInChunk = getXInChunk(position.x);

        int yPosInChunk = cast(int) floor(position.y);

        // Out of bounds.
        if (yPosInChunk < 0 || yPosInChunk >= CHUNK_HEIGHT) {
            writeln("WARNING! trying to write out of bounds! " ~ to!string(yPosInChunk));
        }

        BlockDefinitionResult result = BlockDatabase.getBlockByName(name);

        if (!result.exists) {
            throw new Error("Cannot set to block " ~ name ~ ", does not exist.");
        }

        database[chunkID].data[xPosInChunk][yPosInChunk].blockID = result.definition.id;
    }

    void worldLoad(int currentPlayerChunk) {
        foreach (i; currentPlayerChunk - 1 .. currentPlayerChunk + 2) {
            writeln("loading chunk ", i);
            loadChunk(i);
        }

        // This can get very laggy if old chunks are not unloaded. :)
        unloadOldChunks(currentPlayerChunk);
    }

    bool collideEntityToWorld(ref Vec2d entityPosition, Vec2d entitySize, ref Vec2d entityVelocity,
        CollisionAxis axis) {

        return collision(entityPosition, entitySize, entityVelocity, axis);
    }

private: //* BEGIN INTERNAL API.

    bool collision(ref Vec2d entityPosition, Vec2d entitySize, ref Vec2d entityVelocity, CollisionAxis axis) {
        import utility.collision_functions;

        int oldX = int.min;
        int oldY = int.min;
        int currentX = int.min;
        int currentY = int.min;

        debugDrawPoints = [];

        bool hitGround = false;

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

                debugDrawPoints ~= Vec2d(currentX, currentY);

                ChunkData data = getBlockAtWorldPosition(Vec2d(currentX, currentY));

                // todo: if solid block collide.
                // todo: probably custom blocks one day.

                if (data.blockID == 0) {
                    continue;
                }

                if (axis == CollisionAxis.X) {
                    CollisionResult result = collideXToBlock(entityPosition, entitySize, entityVelocity,
                        Vec2d(currentX, currentY), Vec2d(1, 1));

                    if (result.collides) {
                        entityPosition.x = result.newPosition;
                        entityVelocity.x = 0;
                    }
                } else {

                    
                    CollisionResult result = collideYToBlock(entityPosition, entitySize, entityVelocity,
                        Vec2d(currentX, currentY), Vec2d(1, 1));

                    if (result.collides) {
                        entityPosition.y = result.newPosition;
                        entityVelocity.y = 0;
                        if (result.hitGround) {
                            hitGround = true;
                        }
                    }
                }
            }
        }

        return hitGround;
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
