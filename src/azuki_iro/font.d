module azuki_iro.font;

import std.string;
import bindbc.opengl;
import bindbc.freetype;

import murasaki.io;

import azuki_iro.shader;
import azuki_iro.math.linalg;
import azuki_iro.shaders.font;

public struct Character {
    GLuint TexID;
    float2 Size;
    float2 Bearing;
    GLuint Advance;
}

public class Text2D {

    public GLuint vao, vbo;
    public float2 position;
    public float scale;
    public float3 color;
    public FontShader shader;
    public Font font;

    public float textPadding = 5;
    public string text;

    float maxMarginY = 0;

    public this(float x, float y, string text, Font font, float3 color, float scale) {
        this.position = float2(x,y);
        this.text = text;
        this.font = font;
        this.color = color;
        this.scale = scale;
        this.maxMarginY = 0;

        glGenVertexArrays(1, &vao);
        glGenBuffers(1, &vbo);
        glBindVertexArray(vao);

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * 6 * 4, null, GL_DYNAMIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * float.sizeof, cast(void*) 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);    

        shader = cast(FontShader) Shader.FindShader("UI/Font");
    }

    public void Render(mat4 ortho2DProjection, float2 margin, float windowHeight) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        // activate corresponding render state	
        shader.Bind();
        shader.SetMatrix("projection", ortho2DProjection);
        shader.SetVector("textColor", color);
        glActiveTexture(GL_TEXTURE0);
        glBindVertexArray(vao);

        string[] lines = text.splitLines();

        float x = position.x + margin.x;
        float y;
        float marginPosition = position.y + margin.y;
        if (windowHeight > marginPosition)
            y = windowHeight - marginPosition;
        else
            y = marginPosition - windowHeight; 
        for (int d = 0; d < lines.length; d++) {
            string line = lines[d];
            x = position.x;
            // iterate through all characters
            for (int c = 0; c < line.length; c++) {
                Character ch;
                if ((line[c] in font.characters) is null)
                    ch = font.characters['#'];
                else
                    ch = font.characters[line[c]];

                float w = ch.Size.x * scale;
                float h = ch.Size.y * scale;

                float xpos =    x + ch.Bearing.x * scale;
                float ypos = y + (ch.Size.y - ch.Bearing.y) * scale;
                if ((ypos + h) > maxMarginY)
                    maxMarginY = ypos + h;
                
                // update VBO for each character
                float[4][6] vertices = [
                    [xpos,     ypos + h,   0.0f, 0.0f],            
                    [xpos,     ypos,       0.0f, 1.0f],
                    [xpos + w, ypos,       1.0f, 1.0f],
                    [xpos,     ypos + h,   0.0f, 0.0f],
                    [xpos + w, ypos,       1.0f, 1.0f],
                    [xpos + w, ypos + h,   1.0f, 0.0f]           
                ];

                // render glyph texture over quad
                glBindTexture(GL_TEXTURE_2D, ch.TexID);
                // update content of VBO memory
                glBindBuffer(GL_ARRAY_BUFFER, vbo);
                glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.sizeof, vertices.ptr); 
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                // render quad
                glDrawArrays(GL_TRIANGLES, 0, 6);
                // now advance cursors for next glyph (note that advance is number of 1/64 pixels)
                x += (ch.Advance >> 6) * scale; // bitshift by 6 to get value in pixels (2^6 = 64)
            }
        }
        glBindVertexArray(0);
        glBindTexture(GL_TEXTURE_2D, 0);
        glDisable(GL_BLEND);
    }
}


public class Font {
    public:

        string name;
        FT_Face face;
        Character[char] characters;

        this(string name, FT_Face face, int size) {
            this.name = name;
            this.face = face;
            this.Derive(size);
            
        }

        void Derive(int size) {
            FT_Set_Pixel_Sizes(this.face, 0, size);

            glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

            for (char c = 0; c < 128; c++) {
                if (FT_Load_Char(face, c, FT_LOAD_RENDER)) {
                    Printfln("The Font '%s' is missing character '%s'", this.name, c ~ "");
                    continue;
                }

                GLuint texture;
                glGenTextures(1, &texture);
                glBindTexture(GL_TEXTURE_2D, texture);
                glTexImage2D(
                    GL_TEXTURE_2D,
                    0, 
                    GL_RED,
                    face.glyph.bitmap.width,
                    face.glyph.bitmap.rows,
                    0,
                    GL_RED,
                    GL_UNSIGNED_BYTE,
                    face.glyph.bitmap.buffer
                );
                
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                
                Character character = Character(
                    texture,
                    float2(face.glyph.bitmap.width, face.glyph.bitmap.rows),
                    float2(face.glyph.bitmap_left, face.glyph.bitmap_top),
                    face.glyph.advance.x
                );

                characters[c] = character;
            }

            FT_Done_Face(face);
        }

        

    static: 
        FT_Library ft;

        Font[string] loadedFonts;

        void Init() {
            if (FT_Init_FreeType(&ft)) {
                Printfln("Unable to initialize FreeType library.");
                return;
            }

            loadedFonts["YaheiUI"] = Font.LoadFont("yaheiui.ttf", 42);
        }

        void Release() {
            FT_Done_FreeType(ft);
        }

        Font LoadFont(string name, int size) {        
            Printfln("Loading Font '" ~name ~"'");    
            FT_Face f;
            if (FT_New_Face(ft, ("fonts/" ~ name).toStringz(), 0, &f)) {
                Printfln("Unable to load font \""~name~"\"");
                return null;
            }
            return new Font(name, f, size);
        }
}