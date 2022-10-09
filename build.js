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

        main : async function() {
            let runProgram = process.argv.includes("run");

            System.out.println("Building...");
            let files = imports.fs.readdirSync("./src/");
            
            let line = "ldc2";

            for (let i = 0; i < files.length; i++) {
                let elm = files[i];
                if (imports.fs.statSync("./src/" + elm).isDirectory()) {
                    let newFiles = imports.fs.readdirSync("./src/" + elm).filter(function(v, i, ar) {
                        return v.includes(".d");
                    });
                    newFiles.forEach(function(e) {
                        System.out.println(e);
                        line += " src/" + elm+ "/"+ e;
                    });
                } else {
                    System.out.println(elm);
                    line += " src/" + elm;
                }
            }

            line += " -od=bin";
            if (process.platform == "win32") {
                line += " -of=murasaki-win32.exe";
            } else {
                line += " -of=murasaki-linux";
            }
            imports.childprocess.exec(line, function(err) {
                if (err != null)
                    System.out.println(err);
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