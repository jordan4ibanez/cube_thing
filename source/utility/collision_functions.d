module utility.collision_functions;

import math.rect;
import math.vec2d;
import std.math.traits : sgn;
import std.stdio;

enum CollisionAxis {
    X,
    Y
}

struct CollisionResult {
    bool collides = false;
    double newPosition = 0;
}

// This basically shoves the entity out of the block.
//? Note: This will have issues extremely far out.
private immutable double magicAdjustment = 0.001;

CollisionResult collideXToBlock(Vec2d entityPosition, Vec2d entitySize, Vec2d entityVelocity,
    Vec2d blockPosition, Vec2d blockSize) {

    CollisionResult result;
    result.newPosition = entityPosition.x;

    int dir = cast(int) sgn(entityVelocity.x);

    // This thing isn't moving.
    if (dir == 0) {
        return result;
    }

    // Entity position is on the bottom center of the collisionbox.
    immutable double entityHalfWidth = entitySize.x * 0.5;
    immutable Rect entityRectangle = Rect(entityPosition.x - entityHalfWidth, entityPosition.y,
        entitySize.x, entitySize.y);

    immutable Rect blockRectangle = Rect(blockPosition.x, blockPosition.y, blockSize.x, blockSize.y);

    if (checkCollisionRecs(entityRectangle, blockRectangle)) {
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

CollisionResult collideYToBlock(Vec2d entityPosition, Vec2d entitySize, Vec2d entityVelocity,
    Vec2d blockPosition, Vec2d blockSize) {

    CollisionResult result;
    result.newPosition = entityPosition.y;

    int dir = cast(int) sgn(entityVelocity.y);

    // This thing isn't moving.
    if (dir == 0) {
        return result;
    }

    // Entity position is on the bottom center of the collisionbox.
    immutable double entityHalfWidth = entitySize.x * 0.5;
    immutable Rect entityRectangle = Rect(entityPosition.x - entityHalfWidth, entityPosition.y,
        entitySize.x, entitySize.y);

    immutable Rect blockRectangle = Rect(blockPosition.x, blockPosition.y, blockSize.x, blockSize.y);

    if (checkCollisionRecs(entityRectangle, blockRectangle)) {
        result.collides = true;
        if (dir <= 0) {
            // Kick up. This is the safety default.
            writeln("kick up");

            result.newPosition = blockPosition.y + blockSize.y + magicAdjustment;
        } else {
            // Kick down.
            writeln("kick down");
            result.newPosition = blockPosition.y - magicAdjustment;
        }
    }

    return result;
}
