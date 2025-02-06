module game.player;

import controls.keyboard;
import raylib;
import utility.collision_functions;
import utility.delta;
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

public: //* BEGIN PUBLIC API.

    Vector2 getSize() {
        return size;
    }

    Vector2 getPosition() {
        return position;
    }

    float getWidth() {
        return size.y;
    }

    float getHalfWidth() {
        return size.x * 0.5;
    }

    Vector2 getVelocity() {
        return velocity;
    }

    void setPosition(Vector2 newPosition) {
        position = newPosition;
    }

    void setVelocity(Vector2 newVelocity) {
        velocity = newVelocity;
    }

    Rectangle getRectangle() {
        Vector2 centeredPosition = centerCollisionboxBottom(position, size);
        return Rectangle(centeredPosition.x, centeredPosition.y, size.x, size.y);
    }

    void draw() {
        DrawRectangleV(centerCollisionboxBottom(position, size), size, Colors.WHITE);
    }

    void move() {
        double delta = Delta.getDelta();
        Vector2 playerPos = getPosition();
        Vector2 playerSize = getSize();
        Vector2 playerVelocity = getVelocity();

        //? Controls first.
        if (Keyboard.isDown(KeyboardKey.KEY_RIGHT)) {
            playerVelocity.x += delta * 0.0001;
        } else if (Keyboard.isDown(KeyboardKey.KEY_LEFT)) {
            playerVelocity.x -= delta * 0.0001;
        } else {
            import std.math.algebraic : abs;
            import std.math.traits : sgn;

            float valSign = sgn(playerVelocity.x);
            playerVelocity.x = (abs(playerVelocity.x) - (delta * 0.0001)) * valSign;
        }

        if (Keyboard.isDown(KeyboardKey.KEY_DOWN)) {
            playerVelocity.y += delta * 0.0001;
        } else if (Keyboard.isDown(KeyboardKey.KEY_UP)) {
            playerVelocity.y -= delta * 0.0001;
        } else {
            import std.math.algebraic : abs;
            import std.math.traits : sgn;

            float valSign = sgn(playerVelocity.y);
            playerVelocity.y = (abs(playerVelocity.y) - (delta * 0.0001)) * valSign;
        }

        //? Then apply X axis.
        playerPos.x += playerVelocity.x;

        // CollisionResult res = collideXToBlock(playerPos, playerSize, playerVelocity, sampleBlockPosition, sampleBlockSize);
        // if (res.collides) {
        //     playerVelocity.x = 0;
        //     playerPos.x = res.newPosition;
        // }

        // //? Finally apply Y axis.
        playerPos.y += playerVelocity.y;

        // res = collideYToBlock(playerPos, playerSize, playerVelocity, sampleBlockPosition, sampleBlockSize);

        // if (res.collides) {
        //     playerPos.y = res.newPosition;
        //     playerVelocity.y = 0;
        // }

        setVelocity(playerVelocity);
        setPosition(playerPos);
    }

private: //* BEGIN INTERNAL API.

}
