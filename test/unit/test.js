const getVariable = (name, path, payload) => {
	switch (name) {
		case 'response.content':
			return payload;
			break;
		case 'proxy.pathsuffix':
			return path;
			break;
		default:
			return '';
	}
}

const path = require('path');
const fs = require('fs-extra');
const _ = require('lodash');
const scriptName = '../../apiproxy/resources/jsc/transformJSON.js';

let payloads;
let spy;

describe('transforming JSON payloads', () => {
	// Applies only to tests in this describe block
	beforeAll(() => {
		let filenames;
		return fs.readdir('json')
		.then(result => {
			return result.filter(item => item.endsWith('.json'));
		}).then(result => {
			filenames = result;
			return Promise.all(result.map(filename => {
				return fs.readFile(path.join('json', filename));
			}));
		}).then(result => {
			payloads = _.zipObject(filenames, result);
		});
	});

	beforeEach(() => {
		global.context = {
			getVariable: jest.fn().mockName('getVariable'),
			setVariable: jest.fn().mockName('setVariable').mockImplementation((name, value) => {})
		};
		jest.resetModules();
	});

	test('transforming /books response', () => {
		global.context.getVariable.mockImplementation(name => {
			return getVariable(name, '/books', payloads['getBooks.json']);
		});
		require(scriptName);
		expect(Array.isArray(JSON.parse(global.context.setVariable.mock.calls[0][1]))).toBeTruthy();
	});

	test('transforming /books/search response', () => {
		global.context.getVariable.mockImplementation(name => {
			return getVariable(name, '/books/search', payloads['searchBooks.json']);
		});
		require(scriptName);
		expect(Array.isArray(JSON.parse(global.context.setVariable.mock.calls[0][1]))).toBeTruthy();
	});

	test('transforming /books/{bookId} response', () => {
		global.context.getVariable.mockImplementation(name => {
			return getVariable(name, '/books/3960590c-bdd1-4e6b-9e7b-383f3314a4aa', payloads['getBookById.json']);
		});
		require(scriptName);
		expect(JSON.parse(global.context.setVariable.mock.calls[0][1]).id).toBeDefined();
	});

});