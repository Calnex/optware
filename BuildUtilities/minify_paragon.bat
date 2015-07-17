python minify2.py ^
    --type="js" ^
    --output="%WORKSPACE%\Server\Software\Endor\Web\WebApp\wwwroot\ngApps\Paragon\paragonApp.min.js" ^
    --folder-exclusions="\\test \\Vendor \\img \\css" ^
    --file-inclusions="*.js" ^
    --file-exclusions="-spec.js" ^
    --folder-source="%WORKSPACE%\Server\Software\Endor\Web\WebApp\wwwroot\ngApps\Paragon" ^
    --java-interpreter="C:/Program Files/java/jre7/bin/java.exe" ^
    --jar-file="C:/Optware/BuildUtilities/yuicompressor-2.4.7.jar"