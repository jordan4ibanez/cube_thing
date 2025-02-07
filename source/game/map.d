module game.map;

import graphics.render;
import raylib.raylib_types;
import std.random;
import std.stdio;

immutable public int CHUNK_WIDTH = 32;
immutable public int CHUNK_HEIGHT = 256;

// class ChunkData {

// }

class Chunk {
    int[CHUNK_HEIGHT][CHUNK_WIDTH] data;
}

static final const class Map {
static:
private:

    Chunk[int] database;

public: //* BEGIN PUBLIC API.

    void draw() {
        foreach (chunkWorldPosition, thisChunk; database) {
            foreach (x; 0 .. CHUNK_WIDTH) {
                foreach (y; 0 .. CHUNK_HEIGHT) {

                    if (thisChunk.data[x][y] == 0) {
                        continue;
                    }

                    // +1 on Y because it's drawn with the origin at the top left.
                    Vector2 position = Vector2((chunkWorldPosition * CHUNK_WIDTH) + x, y + 1);

                    Render.rectangle(position, Vector2(1, 1), Colors.ORANGE);

                    Render.rectangleLines(position, Vector2(1, 1), Colors.WHITE);
                }
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

        //? This is a placeholder.

        auto rnd = Random(unpredictableSeed());

        foreach (x; 0 .. CHUNK_WIDTH) {
            foreach (y; 0 .. CHUNK_HEIGHT) {
                int data = uniform(0, 2, rnd);
                thisChunk.data[x][y] = data;
            }
        }
    }

private: //* BEGIN INTERNAL API.

}
