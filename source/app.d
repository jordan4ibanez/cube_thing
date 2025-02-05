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

		CameraHandler.setZoom(100.0);

		BeginDrawing();
		{
			//! Note: DrawTexture and DrawTexturePro are batched as long as you use the same texture.

			ClearBackground(Colors.BLACK);

			CameraHandler.begin();
			{
				DrawRectangle(0, 0, 1, 2, Colors.WHITE);

			}
			CameraHandler.end();
		}
		EndDrawing();
	}
}
