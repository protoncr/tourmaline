# Generates virtual doc files for the mkdocs site.
# You can also run this script directly to actually write out those files, as a preview.

import collections
import mkdocs_gen_files

root = mkdocs_gen_files.config['plugins']['mkdocstrings'].get_handler('crystal').collector.root

def write_file(abs_id, filename):
    with mkdocs_gen_files.open(filename, 'w') as f:
        # Write the entry of a top-level alias (e.g. `AED`) on the same page as the aliased item.
        for root_typ in root.types:
            if root_typ.kind == "alias":
                if root_typ.aliased == abs_id:
                    f.write(f'::: {root_typ.abs_id}\n\n')

        f.write(f'::: {abs_id}\n\n')

for typ in root.lookup("Tourmaline").walk_types():
    filename = 'api_reference/' + '/'.join(typ.abs_id.split('::')) + '/index.md'
    write_file(typ.abs_id, filename)

write_file('Tourmaline', 'api_reference/Tourmaline/index.md')
write_file('String', 'api_reference/String.md')