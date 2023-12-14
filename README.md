# Level_gen
 
This script is for a game level generator. It extends the Node class in Godot, which is the base class for all scene tree nodes.

The script starts by defining several constants and variables that can be adjusted to customize the level generation. These include the number of cells in a room (RSC), the size of the tiles (SIZE), the chance of enemy spawn (ENEMY_SPAWN_CHANCE), the chance of object spawn in the center (PRES_DILD_SPAWN_CHANCE), the size of the passage between chunks (PASSAGE_SIZE), and the number of rooms (room_count).

The script also defines several patterns for different types of rooms, such as double rooms, G rooms, and square rooms.

The _ready() function is called when the node and its children have entered the scene tree. It sets the tile set for the TileMap and calls the generate_level() function to start the level generation process.

The generate_level() function orchestrates the level generation process. It starts by creating a random walk to determine the positions of the rooms. Then it initializes the information about each room and chooses the type of each room based on the defined chances. It also arranges the outputs and inputs of the rooms and creates the chunks from the tiles. Finally, it adds passages between the chunks and the rooms.

The script includes several helper functions to support the level generation process. These include functions to check the validity of room placement, create auxiliary rooms, determine if a path is diagonal, find the neighbors of a point, build a tree using the Breadth-First Search (BFS) algorithm, arrange the outputs and inputs based on the BFS tree, generate the tiles of a chunk, and add passages between chunks and rooms.

Please note that this is a high-level overview and does not cover all the details of the code. For a complete understanding, you should read the code and comments in the script. The script is well-commented and should be relatively easy to follow if you are familiar with Godot and GDScript. If you have any specific questions about the code, feel free to ask!
