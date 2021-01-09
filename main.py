# mkdocs macros

def define_env(env):
    "Hook function"

    @env.macro
    def iter_crystal_type(kind):
        root = env.conf['plugins']['mkdocstrings'].get_handler('crystal').collector.root
        return root.lookup(kind).types