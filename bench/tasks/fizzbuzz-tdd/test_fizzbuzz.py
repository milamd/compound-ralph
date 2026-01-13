"""Tests for FizzBuzz implementation."""

import pytest
from fizzbuzz import fizzbuzz


class TestFizzBuzz:
    """Test suite for fizzbuzz function."""

    def test_returns_number_for_1(self):
        assert fizzbuzz(1) == "1"

    def test_returns_number_for_2(self):
        assert fizzbuzz(2) == "2"

    def test_returns_fizz_for_3(self):
        assert fizzbuzz(3) == "Fizz"

    def test_returns_number_for_4(self):
        assert fizzbuzz(4) == "4"

    def test_returns_buzz_for_5(self):
        assert fizzbuzz(5) == "Buzz"

    def test_returns_fizz_for_6(self):
        assert fizzbuzz(6) == "Fizz"

    def test_returns_fizz_for_9(self):
        assert fizzbuzz(9) == "Fizz"

    def test_returns_buzz_for_10(self):
        assert fizzbuzz(10) == "Buzz"

    def test_returns_fizzbuzz_for_15(self):
        assert fizzbuzz(15) == "FizzBuzz"

    def test_returns_fizzbuzz_for_30(self):
        assert fizzbuzz(30) == "FizzBuzz"

    def test_returns_fizzbuzz_for_45(self):
        assert fizzbuzz(45) == "FizzBuzz"

    def test_returns_number_for_7(self):
        assert fizzbuzz(7) == "7"

    def test_returns_number_for_11(self):
        assert fizzbuzz(11) == "11"
