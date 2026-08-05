float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 norm(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., norm(vec2(2., 2.), 0.).x, distance);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}
float ease(float x) {
    return pow(1.0 - x, 3.0);
}

const vec4 TRAIL_COLOR = vec4(1.0, 1.0, 1.0, 1.0);
const float DURATION = 0.3; //IN SECONDS
// Strength of the trail over the terminal content, 1.0 being fully opaque. The
// alpha of TRAIL_COLOR cannot express this, as the trail is mixed against the
// terminal color rather than alpha-blended over it.
const float OPACITY = 0.25;
// How far the glow spreads past the trail shape, in units where 1.0 spans half
// the viewport height: on a 1080p screen 0.001 is about half a pixel.
const float BLOOM = 0.003;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    // Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = norm(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    // Normalization for cursor position and size;
    // cursor xy has the postion in a space of -1 to 1;
    // zw has the width and height
    vec4 currentCursor = vec4(norm(iCurrentCursor.xy, 1.), norm(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(norm(iPreviousCursor.xy, 1.), norm(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    // Each cursor contributes both corners of the one edge facing the other
    // cursor, so the quad's cross-section is a cursor edge rather than its
    // diagonal and the trail spans the gap between the two. Which pair of edges
    // faces the other cursor depends on the dominant axis of travel: the
    // vertical edges when moving mostly sideways, the horizontal ones otherwise.
    vec2 travel = centerCC - centerCP;
    float isSideways = step(abs(travel.y), abs(travel.x));

    float towardsRight = step(previousCursor.x, currentCursor.x);
    float xCurrent = currentCursor.x + currentCursor.z * (1.0 - towardsRight);
    float xPrevious = previousCursor.x + previousCursor.z * towardsRight;

    float towardsTop = step(previousCursor.y, currentCursor.y);
    float yCurrent = currentCursor.y - currentCursor.w * towardsTop;
    float yPrevious = previousCursor.y - previousCursor.w * (1.0 - towardsTop);

    vec2 v0 = mix(vec2(currentCursor.x, yCurrent), vec2(xCurrent, currentCursor.y - currentCursor.w), isSideways);
    vec2 v1 = mix(vec2(currentCursor.x + currentCursor.z, yCurrent), vec2(xCurrent, currentCursor.y), isSideways);
    vec2 v2 = mix(vec2(previousCursor.x + previousCursor.z, yPrevious), vec2(xPrevious, previousCursor.y), isSideways);
    vec2 v3 = mix(vec2(previousCursor.x, yPrevious), vec2(xPrevious, previousCursor.y - previousCursor.w), isSideways);

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    // Distance between cursors determine the total length of the parallelogram;
    float lineLength = distance(centerCC, centerCP);

    //trailblaze
    vec4 trail = mix(TRAIL_COLOR, fragColor, 1. - smoothstep(0., sdfTrail + BLOOM, BLOOM));
    trail = mix(trail, TRAIL_COLOR, step(sdfTrail + BLOOM, 0.));
    vec4 blazed = mix(trail, fragColor, 1. - smoothstep(0., sdfCurrentCursor, easedProgress * lineLength));
    fragColor = mix(fragColor, blazed, OPACITY);
}
