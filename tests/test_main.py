from main import greeting


def test_greeting_is_nonempty_string():
    result = greeting()
    assert isinstance(result, str)
    assert result


def test_greeting_has_expected_shape():
    result = greeting()
    assert result.startswith('Hello from ')
    assert result.endswith('!')
