shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float strength : hint_range(0.0, 50.0) = 8.0;
uniform float wind_wave_size : hint_range(0.0, 500.0) = 100.0; // Размер волны ветра

void vertex() {
    // Двигаем только верхние вершины (0 и 3)
    float sway_factor = 0.0;
    if (VERTEX_ID == 0 || VERTEX_ID == 3) {
        sway_factor = 1.0;
    }

    // Получаем позицию вершины в мировых координатах (или координатах слоя)
    // MODEL_MATRIX содержит позицию конкретного тайла на карте
    vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;

    // Создаем фазовое смещение на основе позиции X
    // Благодаря этому трава слева и справа будет качаться в разное время
    float phase_shift = world_pos.x / wind_wave_size;

    // Вычисляем покачивание с учетом времени и позиции
    float wind = sin((TIME * speed) + phase_shift);
    
    // Добавим немного хаоса (вторую волну), чтобы движение не было слишком циклическим
    wind += cos((TIME * speed * 0.6) + (phase_shift * 1.5)) * 0.3;
    
    // Применяем сдвиг
    VERTEX.x += wind * strength * sway_factor;
}