import std.stdio;

import controls.keyboard;
import game.player;
import graphics.camera_handler;
import graphics.font_handler;
import raylib;
import std.math.traits;
import utility.collision_functions;
import utility.delta;
import utility.window;

void main() {

	scope (exit) {
		// FontHandler.terminate();
		// ShaderHandler.terminate();
		// TextureHandler.terminate();
		// ModelHandler.terminate();
		Window.terminate();
		CameraHandler.terminate();
	}

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

	Window.initialize();

	CameraHandler.initialize();

	Vector2 sampleBlockPosition = Vector2(0, 0);
	Vector2 sampleBlockSize = Vector2(1, 1);

	while (Window.shouldStayOpen()) {

		CameraHandler.centerToPlayer();

		double delta = Delta.getDelta();

		//! BEGIN TESTING COLLISION.

		Vector2 playerPos = Player.getPosition();
		Vector2 playerSize = Player.getSize();

		// todo: swap dir for a sign made from velocity.
		byte dir = 0;

		if (Keyboard.isDown(KeyboardKey.KEY_RIGHT)) {
			playerPos.x += delta;
			dir = 1;
		} else if (Keyboard.isDown(KeyboardKey.KEY_LEFT)) {
			playerPos.x -= delta;
			dir = -1;
		}

		CollisionResult res = collideXToBlock(playerPos, playerSize, Vector2(dir, 0), sampleBlockPosition, sampleBlockSize);
		if (res.collides) {
			playerPos.x = res.newPosition;
		}

		dir = 0;
		if (Keyboard.isDown(KeyboardKey.KEY_DOWN)) {
			playerPos.y += delta;
			dir = 1;
		} else if (Keyboard.isDown(KeyboardKey.KEY_UP)) {
			playerPos.y -= delta;
			dir = -1;
		}

		if (CheckCollisionRecs(Rectangle(playerPos.x - (playerSize.x * 0.5), playerPos.y - playerSize.y,
				playerSize.x, playerSize.y), Rectangle(sampleBlockPosition.x, sampleBlockPosition.y, sampleBlockSize.x,
				sampleBlockSize.y))) {

			immutable magicAdjustment = 0.001;

			if (dir >= 0) {
				// Kick up. This is the safety default.
				writeln("kick up");
				playerPos.y = sampleBlockPosition.y - magicAdjustment;
			} else {
				// Kick down.
				writeln("kick down");
				playerPos.y = sampleBlockPosition.y + sampleBlockSize.y + playerSize.y + magicAdjustment;
			}
		}

		Player.setPosition(playerPos);

		//! END TESTING COLLISION.

		BeginDrawing();
		{
			//! Note: DrawTexture and DrawTexturePro are batched as long as you use the same texture.

			ClearBackground(Colors.BLACK);

			CameraHandler.begin();
			{
				Player.draw();

				DrawRectangleV(sampleBlockPosition, sampleBlockSize, Colors.BLUE);

			}
			CameraHandler.end();

			Vector2 center = Vector2Multiply(Window.getSize(), Vector2(0.5, 0.5));
			DrawCircle(cast(int) center.x, cast(int) center.y, 4, Colors.RED);
		}
		EndDrawing();
	}
}
