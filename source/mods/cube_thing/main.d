module mods.cube_thing.main;

import game.block_database;

class CubeThingBlock : BlockDefinition {
    this() {
        this.modName = "CubeThing";
    }
}

void cubeThingMain() {

    CubeThingBlock stone = new CubeThingBlock();
    stone.name = "stone";
    stone.texture = "default_stone.png";
    BlockDatabase.registerBlock(stone);

    CubeThingBlock dirt = new CubeThingBlock();
    dirt.name = "dirt";
    dirt.texture = "default_dirt.png";
    BlockDatabase.registerBlock(dirt);

    CubeThingBlock grass = new CubeThingBlock();
    grass.name = "grass";
    grass.texture = "default_grass.png";
    BlockDatabase.registerBlock(grass);

}
