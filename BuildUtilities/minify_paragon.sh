#! /bin/sh

python minify2.py \
    --type="js" \
    --output="/home/alan/Springbank/Server/Software/Endor/Web/WebApp/wwwroot/ngApps/Paragon/paragonApp.min.js" \
    --folder-exclusions="\\test \\Vendor \\img \\css" \
    --file-inclusions="*.js" \
    --file-exclusions="-spec.js" \
    --scratch-folder="/home/alan/Documents/Development/Python/minify/scratch" \
    --folder-source="/home/alan/Springbank/Server/Software/Endor/Web/WebApp/wwwroot/ngApps/Paragon" \
    --java-interpreter=/usr/bin/java \
    --jar-file="/home/alan/Documents/Development/Python/minify/yuicompressor-2.4.7.jar"
