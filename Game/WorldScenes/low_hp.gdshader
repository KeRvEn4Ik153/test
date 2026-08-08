shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Красный цвет
uniform float intensity : hint_range(0.0, 1.0) = 0.0; // Сила эффекта (управляется из скрипта)
uniform float softness : hint_range(0.0, 1.0) = 0.5;  // Плавность перехода краев

void fragment() {
    // Получаем UV координаты экрана и находим расстояние от центра
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
    // Вычисляем маску виньетки
    float vignette = smoothstep(0.8 - softness, 0.5, dist);
    
    // Смешиваем прозрачность на основе интенсивности
    COLOR = vec4(vignette_color.rgb, vignette * intensity);
}