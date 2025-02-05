module game.player;

import raylib;
import utility.drawing_functions;

static final const class Player {
static:
private:

    //? Note: Entities position is at the bottom center of the collision box.
    /*
    |------------|
    |            |
    |            |
    |            |
    |            |
    |            |
    |            |
    |            |
    |            |
    |------X-----|
           ^
           |-------- Actual position
    */

    Vector2 size = Vector2(0.6, 1.8);
    Vector2 position = Vector2(0, 0);

    //* BEGIN PUBLIC API.

    public Vector2 getSize() {
        return size;
    }

    public Vector2 getPosition() {
        return position;
    }

    public Rectangle getRectangle() {
        Vector2 centeredPosition = centerCollisionboxBottom(position, size);
        return Rectangle(centeredPosition.x, centeredPosition.y, size.x, size.y);
    }

    public void draw() {
        DrawRectangleV(centerCollisionboxBottom(position, size), size, Colors.WHITE);
    }

    public void setPosition(Vector2 newPosition) {
        position = newPosition;
    }

    //* BEGIN INTERNAL API.

}
