module game.block_database;

import graphics.texture_handler;

class BlockDefinition {
    string name = null;
    string modName = null;
    string texture = null;
}

struct BlockResult {
    BlockDefinition definition = null;
    bool exists = false;
}

static final const class BlockDatabase {
static:
private:

    // Faster access based on ID or name.
    BlockDefinition[string] nameDatabase;
    BlockDefinition[int] idDatabase;

public: //* BEGIN PUBLIC API.

    void registerBlock(BlockDefinition newBlock) {

        if (newBlock.name is null) {
            throw new Error("Name for block is null.");
        }

        if (newBlock.name in nameDatabase) {
            throw new Error("Trying to overwrite block " ~ newBlock.name);
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

        nameDatabase[newBlock.name] = newBlock;

    }

    BlockResult getBlockByID(int id) {
        if (id !in idDatabase) {
            return BlockResult();
        }

        return BlockResult(idDatabase[id], true);
    }

    BlockResult getBlockByName(string name) {
        if (name !in nameDatabase) {
            return BlockResult();
        }
        return BlockResult(nameDatabase[name], true);
    }

private: //* BEGIN INTERNAL API.

}
