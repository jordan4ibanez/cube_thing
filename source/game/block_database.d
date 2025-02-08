module game.block_database;

import graphics.texture_handler;

class BlockDefinition {
    string name = null;
    string modName = null;
    string texture = null;
    int id = -1;
}

struct BlockResult {
    BlockDefinition definition = null;
    bool exists = false;
}

static final const class BlockDatabase {
static:
private:

    BlockDefinition[string] databaseName;
    BlockDefinition[int] databaseID;

public: //* BEGIN PUBLIC API.

    void registerBlock(BlockDefinition newBlock) {

        if (newBlock.name is null) {
            throw new Error("Name for block is null.");
        }

        if (newBlock.name in databaseName) {
            throw new Error("Trying to override block " ~ newBlock.name);
        }

        if (newBlock.modName is null) {
            throw new Error("Mod name for block is null.");
        }

        if (newBlock.texture is null) {
            throw new Error("Texture for block is null.");
        }

        if (!TextureHandler.hasTexture(newBlock.texture)) {
            throw new Error("Texture for block does not exist.");
        }

        if (newBlock.id in databaseID) {
            throw new Error("Tried to override block " ~ databaseID[newBlock.id].name);
        }

        databaseName[newBlock.name] = newBlock;
        databaseID[newBlock.id] = newBlock;
    }

    BlockResult getBlockByID(int id) {
        if (id !in databaseID) {
            return BlockResult();
        }

        return BlockResult(databaseID[id], true);
    }

    BlockResult getBlockByName(string name) {
        if (name !in databaseName) {
            return BlockResult();
        }
        return BlockResult(databaseName[name], true);
    }

private: //* BEGIN INTERNAL API.

}
