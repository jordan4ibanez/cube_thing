module game.map;

import graphics.render;
import raylib.raylib_types;
import std.stdio;

immutable int CHUNK_WIDTH = 32;
immutable int CHUNK_HEIGHT = 128;

class Chunk {
    int[CHUNK_WIDTH][CHUNK_HEIGHT] data;
}

static final const class Map {
static:
private:

    Chunk[int] database;

public: //* BEGIN PUBLIC API.

    void draw() {
        foreach (key, value; database) {
            foreach (x; 0 .. CHUNK_WIDTH) {
                foreach (y; 0 .. 1) {
                    
                    Vector2 position = Vector2(x, y + 1);

                    Render.rectangle(position, Vector2(1, 1), Colors.ORANGE);

                    Render.rectangleLines(position, Vector2(1, 1), Colors.WHITE);
                }
            }
        }
    }

    void initialize() {
        database[0] = new Chunk();
    }

private: //* BEGIN INTERNAL API.

}
