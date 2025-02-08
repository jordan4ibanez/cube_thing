module mods.cube_thing.main;

import game.block_database;

class CubeThingBlock : BlockDefinition {
    this() {
        this.modName = "CubeThing";
    }
}

void cubeThingMain() {

    CubeThingBlock dirt = new CubeThingBlock();
    dirt.name = "dirt";
    dirt.texture = "default_dirt.png";

    BlockDatabase.registerBlock(dirt);

}
