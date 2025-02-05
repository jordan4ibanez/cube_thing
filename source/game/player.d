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
    Vector2 velocity = Vector2(0, 0);

    //* BEGIN PUBLIC API.

    public Vector2 getSize() {
        return size;
    }

    public Vector2 getPosition() {
        return position;
    }

    public float getWidth() {
        return size.y;
    }

    public float getHalfWidth() {
        return size.x * 0.5;
    }

    public Vector2 getVelocity() {
        return velocity;
    }

    public void setPosition(Vector2 newPosition) {
        position = newPosition;
    }

    public void setVelocity(Vector2 newVelocity) {
        velocity = newVelocity;
    }

    public Rectangle getRectangle() {
        Vector2 centeredPosition = centerCollisionboxBottom(position, size);
        return Rectangle(centeredPosition.x, centeredPosition.y, size.x, size.y);
    }

    public void draw() {
        DrawRectangleV(centerCollisionboxBottom(position, size), size, Colors.WHITE);
    }

    //* BEGIN INTERNAL API.

}
