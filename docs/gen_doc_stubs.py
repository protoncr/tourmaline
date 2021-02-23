# Generates virtual doc files for the mkdocs site.
# You can also run this script directly to actually write out those files, as a preview.

import collections
import mkdocs_gen_files

root = mkdocs_gen_files.config['plugins']['mkdocstrings'].get_handler('crystal').collector.root

for typ in root.walk_types():
    filename = 'api_reference/' + '/'.join(typ.abs_id.split('::')) + '/index.md'

    with mkdocs_gen_files.open(filename, 'w') as f:
        f.write(f'# ::: {typ.abs_id}\n\n')

    if typ.locations:
        mkdocs_gen_files.set_edit_path(filename, typ.locations[0].url)
