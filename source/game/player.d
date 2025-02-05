module game.player;

import raylib;
import utility.drawing_functions;

static final const class Player {
static:
private:

    //? Note: Entities position is at the bottom center of the collision box.

    Vector2 size = Vector2(0.6, 1.8);
    Vector2 position = Vector2(0, 0);

    //* BEGIN PUBLIC API.

    public Vector2 getSize() {
        return size;
    }

    public Vector2 getPosition() {
        return position;
    }

    public void draw() {
        DrawRectangleV(centerCollisionboxBottom(position, size), size, Colors.WHITE);
    }

    //* BEGIN INTERNAL API.

}
