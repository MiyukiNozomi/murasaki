const { stringify } = require("querystring");

const System = function() {
    return {
        out: {
            println: function(msg) {
                console.log(msg);
            },
            print: function(msg) {
                process.stdout.write(msg);
            }
        }
    };
}();

const program = function() {
    let imports = {}
    let exports = {
        importModules : function() {
            imports =  {
                fs : require("fs"),
                childprocess: require("child_process")
            }
        },
        
        filesToCompile : "",

        listFiles : function(folder) {
            let files = imports.fs.readdirSync(folder);
            files.forEach(elm => {
                let fl = folder + "/" + elm;
                if (imports.fs.statSync(fl).isDirectory()) {
                    this.listFiles(fl);
                } else {
                    this.filesToCompile += fl + " ";
                }
            });
        },

        main : async function() {
            let runProgram = process.argv.includes("run");

            System.out.println("Building...");
            
            let line = "ldc2";
            let isDebug = false;
            process.argv.forEach((elm) =>{ 
                if (elm.startsWith("/use:")) {
                    let cc = elm.substring(5, elm.length);
                    line = cc;
                }
                if (elm == "/debug") {
                    isDebug = true;
                }
            });
            System.out.println("Using compiler: " + line);
            if (isDebug) {
                System.out.println("Debug Mode!");
            }
            
            // for DMD
            if (line == "dmd") {
                if (isDebug)
                    line += " -debug";
                line += " -version=GL_33";
            }
            // for LDC2
            else if (line == "ldc2") {
                if (isDebug)
                    line += " -d-debug -g";
                line += " --d-version=GL_33";
            }

            this.listFiles("lib/vendor");
            this.listFiles("src");

            line += " " + this.filesToCompile;

            line += " -od=bin";
            if (process.platform == "win32") {
                line += " -of=murasaki-win32.exe";
            } else {
                line += " -of=murasaki-linux";
            }
            imports.childprocess.exec(line, function(err) {
                if (err != null) {
                    System.out.println("##########  Build Failed!!!  ##########");
                    System.out.println(err);
                    System.out.println("##########  Build Failed!!!  ##########");
                } else {
                    System.out.println("########## BUILD SUCCESS #########");
                }
            });

            if (runProgram) {
                System.out.println("Executing..");
                imports.childprocess.exec("main.exe");
            }
        }
    }
    return exports;
};
let pm = program();

pm.importModules();
pm.main();