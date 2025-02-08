module game.player;

import controls.keyboard;
import game.map;
import graphics.render;
import raylib;
import std.math.algebraic : abs;
import std.math.rounding;
import std.math.traits : sgn;
import std.stdio;
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

    // todo: replace this with double type!

    Vector2 size = Vector2(0.6, 1.8);
    Vector2 position = Vector2(100_000, 0);
    Vector2 velocity = Vector2(0, 0);
    int inChunk = int.max;
    bool firstGen = true;

public: //* BEGIN PUBLIC API.

    Vector2 getSize() {
        return size;
    }

    Vector2 getPosition() {
        return position;
    }

    double getWidth() {
        return size.y;
    }

    double getHalfWidth() {
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
        Render.rectangle(centerCollisionboxBottom(position, size), size, Colors.WHITE);
    }

    void move() {
        double delta = Delta.getDelta();

        immutable double acceleration = 20;
        immutable double deceleration = 25;

        // writeln(velocity.x);

        //? Controls first.
        if (Keyboard.isDown(KeyboardKey.KEY_RIGHT)) {
            if (sgn(velocity.x) < 0) {
                velocity.x += delta * deceleration;
            } else {
                velocity.x += delta * acceleration;
            }
        } else if (Keyboard.isDown(KeyboardKey.KEY_LEFT)) {
            if (sgn(velocity.x) > 0) {
                velocity.x -= delta * deceleration;
            } else {
                velocity.x -= delta * acceleration;
            }
        } else {
            if (abs(velocity.x) > delta * deceleration) {
                double valSign = sgn(velocity.x);
                velocity.x = (abs(velocity.x) - (delta * deceleration)) * valSign;
            } else {
                velocity.x = 0;
            }
        }

        if (Keyboard.isDown(KeyboardKey.KEY_UP)) {
            if (sgn(velocity.y) < 0) {
                velocity.y += delta * deceleration;
            } else {
                velocity.y += delta * acceleration;
            }
        } else if (Keyboard.isDown(KeyboardKey.KEY_DOWN)) {
            if (sgn(velocity.y) > 0) {
                velocity.y -= delta * deceleration;
            } else {
                velocity.y -= delta * acceleration;
            }
        } else {
            if (abs(velocity.y) > delta * deceleration) {
                double valSign = sgn(velocity.y);
                velocity.y = (abs(velocity.y) - (delta * deceleration)) * valSign;
            } else {
                velocity.y = 0;
            }
        }

        //? Then apply X axis.
        position.x += velocity.x * delta;

        // CollisionResult res = collideXToBlock(playerPos, playerSize, playerVelocity, sampleBlockPosition, sampleBlockSize);
        // if (res.collides) {
        //     playerVelocity.x = 0;
        //     playerPos.x = res.newPosition;
        // }

        // //? Finally apply Y axis.
        position.y += velocity.y * delta;

        // todo: the void.
        // if (position.y <= 0) {
        //     position.y = 0;
        // }

        // res = collideYToBlock(playerPos, playerSize, playerVelocity, sampleBlockPosition, sampleBlockSize);

        // if (res.collides) {
        //     playerPos.y = res.newPosition;
        //     playerVelocity.y = 0;
        // }

        int oldChunk = inChunk;
        int newChunk = Map.calculateChunkAtWorldPosition(position.x);

        if (oldChunk != newChunk) {
            inChunk = newChunk;
            Map.worldLoad(inChunk);

            // Move the player to the ground level.
            // todo: when mongoDB added, restore old position.
            if (firstGen) {
                position.y = Map.getTop(position.x);
                firstGen = false;
            }
        }
    }

    int inWhichChunk() {
        return inChunk;
    }

private: //* BEGIN INTERNAL API.

}
