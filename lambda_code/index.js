exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "¡Hola desde la lambda!" }),
    };
};  