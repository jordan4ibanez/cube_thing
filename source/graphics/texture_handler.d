module graphics.texture_handler;

import fast_pack;
import raylib;
import std.container;
import std.file;
import std.path;
import std.regex;
import std.stdio;
import std.string;

static final const class TextureHandler {
static:
private:

    Texture2D*[string] database;
    TexturePacker!string textureAtlas;

public: //* BEGIN PUBLIC API.

    void initialize() {
        TexturePackerConfig config;
        config.padding = 3;
        config.width = 128;
        config.height = 128;
        config.expansionAmount = 64;
        textureAtlas = new TexturePacker!string(config);

        foreach (string thisFilePathString; dirEntries("textures", "*.png", SpanMode.depth)) {
            string fileName = baseName(thisFilePathString);
            textureAtlas.pack(fileName, thisFilePathString);
        }

        textureAtlas.saveToFile("atlas.png");
    }

    void loadTexture(string location) {

        // Extract the file name from the location.
        string fileName = () {
            string[] items = location.split("/");
            int len = cast(int) items.length;
            if (len <= 1) {
                throw new Error("[TextureManager]: Texture must not be in root directory.");
            }
            string outputFileName = items[len - 1];
            if (!outputFileName.endsWith(".png")) {
                throw new Error("[TextureManager]: Not a .png");
            }
            return outputFileName;
        }();

        if (fileName in database) {
            throw new Error("[TextureManager]: Tried to overwrite [" ~ fileName ~ "]");
        }

        Texture2D* thisTexture = new Texture2D();
        *thisTexture = LoadTexture(toStringz(location));

        if (!IsTextureValid(*thisTexture)) {
            throw new Error("[TextureManager]: Texture [" ~ location ~ "] is invalid.");
        }

        database[fileName] = thisTexture;
    }

    Texture2D* getTexturePointer(string textureName) {
        if (textureName !in database) {
            throw new Error("[TextureManager]: Texture does not exist. " ~ textureName);
        }

        return database[textureName];
    }

    void deleteTexture(string textureName) {
        if (textureName !in database) {
            throw new Error(
                "[TextureManager]: Texture does not exist. Cannot delete. " ~ textureName);
        }

        Texture* thisTexture = database[textureName];
        UnloadTexture(*thisTexture);
        database.remove(textureName);
    }

    void terminate() {
        foreach (textureName, thisTexture; database) {
            UnloadTexture(*thisTexture);
        }

        database.clear();
    }

private: //* BEGIN INTERNAL API.
}
