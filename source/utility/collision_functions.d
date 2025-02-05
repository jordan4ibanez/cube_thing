module utility.collision_functions;

import raylib;
import std.math.traits : sgn;
import std.stdio;

struct CollisionResult {
    bool collides = false;
    float newPosition = 0;
}

private immutable float magicAdjustment = 0.001;

CollisionResult collideXToBlock(Vector2 entityPosition, Vector2 entitySize, Vector2 entityVelocity,
    Vector2 blockPosition, Vector2 blockSize) {

    CollisionResult result;
    result.newPosition = entityPosition.x;

    int dir = cast(int) sgn(entityVelocity.x);

    // This thing isn't moving.
    if (dir == 0) {
        return result;
    }

    // Entity position is on the bottom center of the collisionbox.
    immutable float entityHalfWidth = entitySize.x * 0.5;
    immutable Rectangle entityRectangle = Rectangle(entityPosition.x - entityHalfWidth, entityPosition.y - entitySize.y,
        entitySize.x, entitySize.y);

    immutable Rectangle blockRectangle = Rectangle(blockPosition.x, blockPosition.y, blockSize.x, blockSize
            .y);

    if (CheckCollisionRecs(entityRectangle, blockRectangle)) {
        // This doesn't kick out in a specific direction on dir 0 because the Y axis check will kick them up as a safety.
        result.collides = true;
        if (dir > 0) {
            // Kick left.
            result.newPosition = blockPosition.x - entityHalfWidth - magicAdjustment;
        } else if (dir < 0) {
            // Kick right.
            result.newPosition = blockPosition.x + blockSize.x + entityHalfWidth + magicAdjustment;
        }
    }

    return result;
}

CollisionResult collideYToBlock(Vector2 entityPosition, Vector2 entitySize, Vector2 entityVelocity,
    Vector2 blockPosition, Vector2 blockSize) {

    CollisionResult result;
    result.newPosition = entityPosition.y;

    int dir = cast(int) sgn(entityVelocity.y);

    // This thing isn't moving.
    if (dir == 0) {
        return result;
    }

    // Entity position is on the bottom center of the collisionbox.
    immutable float entityHalfWidth = entitySize.x * 0.5;
    immutable Rectangle entityRectangle = Rectangle(entityPosition.x - entityHalfWidth, entityPosition.y - entitySize.y,
        entitySize.x, entitySize.y);

    immutable Rectangle blockRectangle = Rectangle(blockPosition.x, blockPosition.y, blockSize.x, blockSize
            .y);

    if (CheckCollisionRecs(entityRectangle, blockRectangle)) {
        result.collides = true;
        if (dir >= 0) {
            // Kick up. This is the safety default.
            writeln("kick up");
            result.newPosition = blockPosition.y - magicAdjustment;
        } else {
            // Kick down.
            writeln("kick down");
            result.newPosition = blockPosition.y + blockSize.y + entitySize.y + magicAdjustment;
        }
    }

    return result;
}
