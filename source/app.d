import std.stdio;

import game.player;
import graphics.camera_handler;
import graphics.font_handler;
import raylib;
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

		Vector2 center = Vector2Multiply(Window.getSize(), Vector2(0.5, 0.5));

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

			DrawCircle(cast(int) center.x, cast(int) center.y, 4, Colors.RED);
		}
		EndDrawing();
	}
}
