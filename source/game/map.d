module game.map;

import fast_noise;
import game.biome_database;
import game.block_database;
import graphics.camera_handler;
import graphics.render;
import graphics.texture_handler;
import raylib.raylib_types;
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

public: //* BEGIN PUBLIC API.

    void initialize() {
        noise.seed = 1_010_010;
    }

    void draw() {

        //? Screen draws, bottom left to top right.
        int windowWidth = Window.getWidth();
        int windowHeight = Window.getHeight();

        Vector2 bottomLeft = CameraHandler.screenToWorld(0, 0);
        Vector2 topRight = CameraHandler.screenToWorld(windowWidth, windowHeight);

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

        foreach (x; minX .. maxX + 1) {
            // todo: cache the chunk.
            foreach (y; minY .. maxY + 1) {

                Vector2 position = Vector2(x, y);

                ChunkData thisData = getBlockAtWorldPosition(position);

                if (thisData.blockID == 0) {
                    continue;
                }

                // +1 on Y because it's drawn with the origin at the top left.

                position.y += 1;

                // Render.rectangle(position, Vector2(1, 1), Colors.ORANGE);

                BlockDefinitionResult thisBlockResult = BlockDatabase.getBlockByID(
                    thisData.blockID);

                if (!thisBlockResult.exists) {
                    TextureHandler.drawTexture("unknown.png", position, Vector2(16, 16), Vector2(1, 1));
                } else {
                    TextureHandler.drawTexture(thisBlockResult.definition.texture, position, Vector2(16, 16), Vector2(
                            1, 1));
                }

                // Render.rectangleLines(position, Vector2(1, 1), Colors.WHITE);
            }
        }
    }

    int calculateChunkAtWorldPosition(float x) {
        return cast(int) floor(x / CHUNK_WIDTH);
    }

    ChunkData getBlockAtWorldPosition(Vector2 position) {
        int chunkID = calculateChunkAtWorldPosition(position.x);

        if (chunkID !in database) {
            return ChunkData();
        }

        int xPosInChunk = cast(int) floor(position.x % CHUNK_WIDTH);
        // Account for negatives.
        if (xPosInChunk < 0) {
            xPosInChunk += CHUNK_WIDTH;
        }

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

private: //* BEGIN INTERNAL API.

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

        immutable float baseHeight = 160;

        immutable int basePositionX = chunkPosition * CHUNK_WIDTH;

        BlockDefinitionResult bedrockResult = BlockDatabase.getBlockByName("bedrock");
        if (!bedrockResult.exists) {
            throw new Error("Please do not remove bedrock from the engine.");
        }

        BlockDefinitionResult stoneResult = BlockDatabase.getBlockByID(
            biomeResult.definition.stoneLayerID);

        if (!bedrockResult.exists) {
            throw new Error("Stone does not exist for biome " ~ biomeResult.definition.name);
        }

        foreach (x; 0 .. CHUNK_WIDTH) {

            immutable float selectedNoise = fnlGetNoise2D(&noise, x + basePositionX, 0);

            immutable float noiseScale = 20;

            immutable int selectedHeight = cast(int) floor(baseHeight + (selectedNoise * noiseScale));

            immutable int grassLayer = selectedHeight;
            immutable int dirtLayer = selectedHeight - 3;

            immutable float bedRockNoise = fnlGetNoise2D(&noise, (x + basePositionX) * 256, 0) * 2;

            immutable int bedRockSelectedHeight = cast(int) round(abs(bedRockNoise));

            yStack: foreach (y; 0 .. CHUNK_HEIGHT) {

                if (y > selectedHeight) {
                    break yStack;
                }

                switch (y) {
                case 0: {
                        thisChunk.data[x][y].blockID = bedrockResult.definition.id;
                    }
                    break;
                case 1: .. case 2: {

                        writeln(bedRockSelectedHeight);

                        if (y <= bedRockSelectedHeight) {
                            thisChunk.data[x][y].blockID = bedrockResult.definition.id;
                        } else {
                            thisChunk.data[x][y].blockID = stoneResult.definition.id;
                        }
                    }
                    break;
                default:
                    // air.
                }

                if (y == 0) {

                }

                // int data = uniform(0, 2, rnd);
                // thisChunk.data[x][y].blockID = data;
            }
        }
    }

}
