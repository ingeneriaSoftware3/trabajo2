#!/bin/bash

ffmpeg -f f32le -ac 2 -i $1 audio.$2
