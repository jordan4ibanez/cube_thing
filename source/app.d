import std.stdio;

import controls.keyboard;
import game.player;
import graphics.camera_handler;
import graphics.font_handler;
import raylib;
import std.math.traits;
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

		if (Keyboard.isDown(KeyboardKey.KEY_RIGHT)) {
			playerPos.x += delta;
		} else if (Keyboard.isDown(KeyboardKey.KEY_LEFT)) {
			playerPos.x -= delta;
		}

		// todo: collision detect.

		Rectangle playerRect = Player.getRectangle();

		if (CheckCollisionRecs(playerRect, Rectangle(sampleBlockPosition.x, sampleBlockPosition.y,
				sampleBlockSize.x, sampleBlockSize.y))) {

			// Kick the player out based on the direction they are based in the center of this rectangle.
			// If the player goes too fast, they can phase through the block.
			immutable float blockCenterX = sampleBlockPosition.x + (sampleBlockSize.x * 0.5);
			immutable byte dir = cast(byte) sgn(playerPos.x - blockCenterX);

			// This doesn't kick out in a specific direction on dir 0 because the Y axis check will kick them up.

			float playerHalfWidth = Player.getHalfWidth();

			immutable magicAdjustment = 0.001;

			if (dir < 0) {
				// Kick left.
				playerPos.x = sampleBlockPosition.x - playerHalfWidth - magicAdjustment;
			} else if (dir > 0) {
				// Kick right.
				writeln("right");
				playerPos.x = sampleBlockPosition.x + sampleBlockSize.x + playerHalfWidth + magicAdjustment;
			}

		}

		if (Keyboard.isDown(KeyboardKey.KEY_DOWN)) {
			playerPos.y += delta;
		} else if (Keyboard.isDown(KeyboardKey.KEY_UP)) {
			playerPos.y -= delta;
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
