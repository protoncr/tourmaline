script_path=$(realpath $(dirname $_))
mkdir  -p "$script_path/build" 2> /dev/null
for i in `find $script_path -type f -name "*.cr"`;
do
    echo "Building: $i"
    filename=$(basename "$i")
    out="$script_path/build/${filename%.*}"
    crystal build $i -o $out
done
