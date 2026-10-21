#include <iostream>
#include <memory>
#include <vector>

// Core LiteRT C++ Headers
#include "tensorflow/lite/interpreter.h"
#include "tensorflow/lite/model_builder.h"
#include "tensorflow/lite/kernels/register.h"

int main() {
    // 1. Load the model from file (.tflite)
    const char* model_path = "model.tflite";
    std::unique_ptr<tflite::FlatBufferModel> model = tflite::FlatBufferModel::BuildFromFile(model_path);

    if (!model) {
        std::cerr << "Failed to load model: " << model_path << std::endl;
        return -1;
    }

    // 2. Build the interpreter with the built-in operations resolver
    tflite::ops::builtin::BuiltinOpResolver resolver;
    tflite::InterpreterBuilder builder(*model, resolver);
    std::unique_ptr<tflite::Interpreter> interpreter;

    if (builder(&interpreter) != kTfLiteOk || !interpreter) {
        std::cerr << "Failed to create interpreter!" << std::endl;
        return -1;
    }

    // 3. Allocate tensors for the graph
    if (interpreter->AllocateTensors() != kTfLiteOk) {
        std::cerr << "Failed to allocate tensors!" << std::endl;
        return -1;
    }

    // 4. Fill input buffer (Assuming a simple float input array for illustration)
    int input_index = interpreter->inputs()[0];
    float* input_data = interpreter->typed_tensor<float>(input_index);

    if (input_data) {
        input_data[0] = 5.0f; // model is fit of y = 2x - 1
    }

    // 5. Run inference
    if (interpreter->Invoke() != kTfLiteOk) {
        std::cerr << "Failed to invoke interpreter!" << std::endl;
        return -1;
    }

    // 6. Extract outputs
    int output_index = interpreter->outputs()[0];
    float* output_data = interpreter->typed_tensor<float>(output_index);

    if (output_data) {
        std::cout << "Inference successful! First output element: " << output_data[0] << std::endl;
    }

    return 0;
}
