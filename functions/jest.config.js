module.exports = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    testMatch: [
        '**/src/**/*.spec.ts'
    ],
    maxWorkers: 1,
};