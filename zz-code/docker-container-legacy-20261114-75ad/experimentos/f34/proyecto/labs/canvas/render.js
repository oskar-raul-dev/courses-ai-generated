// labs/canvas/render.js — la prueba de que compiló Y funciona
const { createCanvas } = require('canvas');
const fs = require('fs');

const canvas = createCanvas(400, 200);
const ctx = canvas.getContext('2d');
ctx.fillStyle = '#0b3d2e';
ctx.fillRect(0, 0, 400, 200);
ctx.fillStyle = '#ffffff';
ctx.font = '24px sans-serif';
ctx.fillText('canvas funciona en Debian 10 👋', 20, 110);

fs.writeFileSync('salida.png', canvas.toBuffer('image/png'));
console.log('escrito salida.png');
