module azuki_iro.shader;

import std.string;
import bindbc.opengl;
import std.file : readText;

import murasaki.io;
import azuki_iro.math.linalg;

public abstract class Shader {

    private static Shader[string] loadedShaders;

    public static void AddShader(Shader thing) {
        string name = thing.GetDisplayName();
        if ((name in loadedShaders) !is null) {
            Printfln("WARN: the shader '%s' already exists.", name);
            return;
        }
        loadedShaders[name] = thing;
    }
    
    public static Shader FindShader(string name) {
        if ((name in loadedShaders) is null) {
            Printfln("WARN: Shader not found: '%s'", name);
            return loadedShaders["Standard"];
        }
        return loadedShaders[name];
    }

    public static void LoadShader() {}

    protected GLuint program;
    protected GLuint vertex, fragment;
    protected GLuint[string] uniforms;

    protected string name;
    protected string displayName;

    public string GetName() {return name;}
    public string GetDisplayName() {return displayName;}
    public GLuint GetProgram() {return this.program;}
    public GLuint GetVertex() {return this.vertex;}
    public GLuint GetFragment() {return this.fragment;}

    public this(string name, string displayName = "") {
        this.name = name;
        string vss, fss;
        this.displayName = displayName;
        GLuint vertexShader = MakeShader(name ~ "/" ~ "vertex.glsl", GL_VERTEX_SHADER, vss);
        GLuint fragmentShader = MakeShader(name ~ "/" ~ "fragment.glsl", GL_FRAGMENT_SHADER, fss);

        this.program = glCreateProgram();

        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);

        BindAttributes();

        glLinkProgram(program);
        glValidateProgram(program);

        GLint linkStatus;
        glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);

        char[512] infoLog;
        if (linkStatus != GL_TRUE) {
            glGetProgramInfoLog(program, 512, null, infoLog.ptr);
           // System.("Error! Vertex Shader Compilation Failure!\n", infoLog);
            Printfln("Failed to link program: '%s', error message:\n %s", this.name, infoLog);
        }

        this.vertex = vertexShader;
        this.fragment = fragmentShader;

     //   glDeleteShader(vertexShader);
      //  glDeleteShader(fragmentShader);

        this.Bind();
        Printfln("Parsing Shader's Uniforms for '%s'", name);
        ShaderParser p1 = new ShaderParser(vss);
        ShaderParser p2 = new ShaderParser(fss);
        string[] uniforms1 = p1.ParseUniforms();
        string[] uniforms2 = p2.ParseUniforms();

        foreach(string s ; uniforms1) {
            this.AddUniform(s);
        }
        foreach(string s2 ; uniforms2) {
            this.AddUniform(s2);
        }
        Printfln("Parsing Done!");
        this.Unbind();
    }

    protected void AddUniform(string name) {
        auto uniform = glGetUniformLocation(program, name.toStringz());
        if (uniform == -1) 
            Printfln("ERROR: uniform '%s' wasn't located on shader '%s'", name, this.name);
    
        uniforms[name] = uniform;
    }

    protected void BindAttrib(int attrib, string name) {
        glBindAttribLocation(this.program, attrib, name.toStringz());
    }
    
	public void SetFloat(string name, float value) {
        if ((name in uniforms) is null) {
            Printfln("uniform %s is not known", name);
            return;
        }
		glUniform1f(uniforms[name], value);
	}
	
    
	public void SetVector(string name, float4 plane) {
        if ((name in uniforms) is null) {return;}
		glUniform4f(uniforms[name], plane.x, plane.y, plane.z, plane.w);
	}
	
	public void SetVector(string name, float3 plane) {
        if ((name in uniforms) is null) {return;}
		glUniform3f(uniforms[name], plane.x, plane.y, plane.z);
	}
	
	public void SetVector(string name, float2 vec) {
        if ((name in uniforms) is null) {return;}
		glUniform2f(uniforms[name], vec.x, vec.y);
	}

    public void SetMatrix(string name, mat4 matrix) {
        if ((name in uniforms) is null) {return;}
        glUniformMatrix4fv(uniforms[name], 1, GL_TRUE, matrix.value_ptr);
    }

    public void SetMatrix(string name, mat3 matrix) {
        if ((name in uniforms) is null) {return;}
        glUniformMatrix3fv(uniforms[name], 1, GL_TRUE, matrix.value_ptr);
    }
	
	public void SetBool(string name, bool b) {
        if ((name in uniforms) is null) {return;}
		glUniform1f(uniforms[name], b ? 1: 0);
	}
	
	public void SetInt(string name, int i) {
        if ((name in uniforms) is null) {return;}
		glUniform1i(uniforms[name], i);
	}

	public void BindAttributes() {}

    public void Bind() {
        glUseProgram(this.program);
    }

    public void Unbind() {
        glUseProgram(0);
    }

    private static GLuint MakeShader(string filename, GLenum type, out string rawFile) {
        Printfln("Loading Shader '%s'", filename);
        string file = readText("shaders/" ~ filename);
        rawFile = file;

        GLuint shader = glCreateShader(type);
        const char* source = file.toStringz();
        glShaderSource(shader, 1, &source, null);
        glCompileShader(shader);  
        
        int success;
        char[512] infoLog;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &success);

        if (!success) {
            glGetShaderInfoLog(shader, 512, null, infoLog.ptr);
           // System.("Error! Vertex Shader Compilation Failure!\n", infoLog);
            Printfln("Failed to compile shader: '%s', error message:\n %s", filename, infoLog);
        }
        return shader;
    }

    public override bool opEquals(Object o) {
        Shader e = cast(Shader) o;
        return e.name == this.name;
    }

    public override size_t toHash() {
        size_t h = 0;

        foreach(char c ; name) {
            h = (h << 5) + c;
        }

        return h;
    }
}

// shader parser; no more i will need to type AddUniform for every uniform i add.

import std.ascii;

private enum TokenType {
    Invalid,
    Uniform, Identifier,
    Semicolon,
    EndOfFile
}

private struct Token {
    string data;
    TokenType type;  
}

private class Lexer {

    private:
        char current;
        int position;
        string rawData;

    public:
        this(string data) {
            this.rawData = data;
            this.position = 0;
            this.NextChar();
        }

        char NextChar() {
            char last = current;
            if (position >= rawData.length) {
                current = '\0';
            } else {
                current = rawData[position++];
            }
            return last;
        }

        Token NextToken() {
            while (isWhite(current) && current != '\0') {
                NextChar();
            }

            if (current == '\0')
                return Token("", TokenType.EndOfFile);

            if (isAlpha(current)) {
                string acc = "";
                while ((isAlpha(current) || isDigit(current) || current == '_') && current != '\0') {
                    acc ~= NextChar();
                }
                return Token(acc, acc == "uniform" ? TokenType.Uniform : TokenType.Identifier);
            } else if (current == ';') {
                return Token("" ~ NextChar(), TokenType.Semicolon);
            }

            // invalid; skip
            NextChar();
            return NextToken();
        }

}

private class ShaderParser {
    private Lexer lexer;

    public this(string data) {
        this.lexer = new Lexer(data);
    }

    public string[] ParseUniforms() {   
        string[] uniforms;
        for (Token tk = lexer.NextToken(); tk.type != TokenType.EndOfFile; tk = lexer.NextToken()) {
            if (tk.type == TokenType.Uniform) { // Uniform found;
                string uniform;
                if (ParseUniform(uniform)) {
               //     Printfln("Found Uniform: %s", uniform);
                    uniforms ~= uniform;
                }
            }
        } 
        return uniforms;
    }

    public bool ParseUniform(out string uniformName) {
        // skip type
        Token t = lexer.NextToken();
        // grab name
        t = lexer.NextToken();
        
        if (t.type != TokenType.Identifier) {
            Printfln("Possible syntax error at: '%s' invalid uniform name", t.data);
            return false;
        }
        uniformName = t.data;
        return true;
    
    }
}