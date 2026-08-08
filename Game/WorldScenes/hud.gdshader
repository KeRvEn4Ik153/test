shader_type canvas_item;

// 1. ОБЪЯВЛЯЕМ СЧИТЫВАТЕЛЬ ЭКРАНА ДЛЯ GODOT 4 (Важный шаг!)
// Мы создаем переменную SCREEN_TEXTURE и говорим движку использовать ее как снимок экрана
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Настройка силы размытия экрана (можно менять в инспекторе)
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    // 2. ИСПОЛЬЗУЕМ ВЕРНЫЙ ИДЕНТИФИКАТОР (SCREEN_TEXTURE заглавными буквами)
    // Берем текстуру того, что нарисовано ЗА нашим прямоугольником (саму игру)
    vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    
    // Слегка затемняем картинку, умножая цвета на 0.7 (черный тон)
    color.rgb *= 0.7;
    
    COLOR = color;
}
