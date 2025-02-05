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

			}
			CameraHandler.end();

			DrawCircle(cast(int) center.x, cast(int) center.y, 4, Colors.RED);
		}
		EndDrawing();
	}
}
