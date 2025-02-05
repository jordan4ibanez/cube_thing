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
		Vector2 playerVelocity = Player.getVelocity();

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


		playerPos.x += playerVelocity.x;

		CollisionResult res = collideXToBlock(playerPos, playerSize, playerVelocity, sampleBlockPosition, sampleBlockSize);
		if (res.collides) {
			playerVelocity.x = 0;
			playerPos.x = res.newPosition;
		}

		playerPos.y += playerVelocity.y;

		res = collideYToBlock(playerPos, playerSize, playerVelocity, sampleBlockPosition, sampleBlockSize);

		if (res.collides) {
			playerPos.y = res.newPosition;
			playerVelocity.y = 0;
		}

		Player.setVelocity(playerVelocity);
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
