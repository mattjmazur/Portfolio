"""
implementation of a hashmap using open addressing with quadratic probing
"""

from hash_map_dependency import (DynamicArray, DynamicArrayException, HashEntry,
                        hash_function_1, hash_function_2)


class HashMap:
    def __init__(self, capacity: int, function) -> None:
        """
        Initialize new HashMap that uses
        quadratic probing for collision resolution
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        self._buckets = DynamicArray()

        # capacity must be a prime number
        self._capacity = self._next_prime(capacity)
        for _ in range(self._capacity):
            self._buckets.append(None)

        self._hash_function = function
        self._size = 0

    def __str__(self) -> str:
        """
        Override string method to provide more readable output
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        out = ''
        for i in range(self._buckets.length()):
            out += str(i) + ': ' + str(self._buckets[i]) + '\n'
        return out

    def _next_prime(self, capacity: int) -> int:
        """
        Increment from given number to find the closest prime number
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        if capacity % 2 == 0:
            capacity += 1

        while not self._is_prime(capacity):
            capacity += 2

        return capacity

    @staticmethod
    def _is_prime(capacity: int) -> bool:
        """
        Determine if given integer is a prime number and return boolean
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        if capacity == 2 or capacity == 3:
            return True

        if capacity == 1 or capacity % 2 == 0:
            return False

        factor = 3
        while factor ** 2 <= capacity:
            if capacity % factor == 0:
                return False
            factor += 2

        return True

    def get_size(self) -> int:
        """
        Return size of map
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        return self._size

    def get_capacity(self) -> int:
        """
        Return capacity of map
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        return self._capacity

    def next_index(self, index, counter):
        """
        returns the next-calculated index using quadratic probing, requires 'counter' be updated outside of the function
        """
        return (index + (counter ** 2)) % self._capacity

    def into_empty_index(self, key, value):
        """
        places 'key' and 'value' into the HashMap using quadratic probing to find an empty index
        """
        current_hash = self._hash_function(key)
        index = current_hash % self._capacity
        original_index = index

        j = 0
        while True:
            current_hash_entry = self._buckets.get_at_index(index)
            if current_hash_entry is None or current_hash_entry.is_tombstone:
                self._size += 1
            if current_hash_entry is None or current_hash_entry.is_tombstone or current_hash_entry.key == key:
                self._buckets.set_at_index(index, HashEntry(key=key, value=value))
                self._buckets.get_at_index(index).is_tombstone = False
                return
            else:
                j += 1
                index = self.next_index(index=original_index, counter=j)

    def put(self, key: str, value: object) -> None:
        """
        updates the key/value pair in the hash table. if 'key' is already in the hash table, its corresponding value
        is updated to 'value', otherwise the key/value pair is added to the hash table.
        """
        while self.table_load() >= 0.5:
            self.resize_table(self._capacity * 2)

        self.into_empty_index(key=key, value=value)

    def table_load(self) -> float:
        """
        returns the current hash table load factor
        """
        return self._size / self._capacity

    def empty_buckets(self) -> int:
        """
        returns the number of empty buckets in the hash table
        """
        return self._capacity - self._size

    def resize_table(self, new_capacity: int) -> None:
        """
        changes the capacity of the hash table to 'new_capacity' if 'new_capacity' is a prime number, or the next
        highest prime number if 'new_capacity' is not a prime number
        """

        # build a DynamicArray, 'new_hash_map', and starting with the value passed as 'new_capacity' we increase
        # the value of 'new_capacity' until it is greater than our HashMap's size
        if new_capacity < self._size:
            return

        if not self._is_prime(new_capacity):
            new_capacity = self._next_prime(new_capacity)


        new_hash_map = HashMap(capacity=new_capacity, function=self._hash_function)

        # re-hash and add all the values of our HashMap into new_hash_map
        for i in range(self._capacity):
            current_entry = self._buckets.get_at_index(i)
            if current_entry is None:
                continue
            elif current_entry.is_tombstone is True:
                continue
            else:
                new_hash_map.put(current_entry.key, current_entry.value)

        self._capacity = new_hash_map._capacity
        self._buckets = new_hash_map._buckets

    def get(self, key: str) -> object:
        """
        returns the value associated with 'key', if there is no value associated with 'key' it returns None
        """
        for i in range(self._capacity):
            current_hash_entry = self._buckets.get_at_index(i)
            if current_hash_entry is None or current_hash_entry.key != key or current_hash_entry.is_tombstone is True:
                continue
            else:
                return current_hash_entry.value
        return None

    def contains_key(self, key: str) -> bool:
        """
        returns True if the 'key' is in the hash map, otherwise it returns False
        """
        for i in range(self._capacity):
            current_hash_entry = self._buckets.get_at_index(i)
            if current_hash_entry is None or current_hash_entry.key != key or current_hash_entry.is_tombstone is True:
                continue
            else:
                return True
        return False

    def remove(self, key: str) -> None:
        """
        removes 'key' and its associated value from the hash map
        """
        for i in range(self._capacity):
            current_hash_entry = self._buckets.get_at_index(i)
            if current_hash_entry is None or current_hash_entry.key != key or current_hash_entry.is_tombstone is True:
                continue
            else:
                current_hash_entry.is_tombstone = True
                self._size -= 1
                return

    def clear(self) -> None:
        """
        clears the contents of the hash map
        """
        self._buckets = DynamicArray()
        for _ in range(self._capacity):
            self._buckets.append(None)
        self._size = 0

    def get_keys_and_values(self) -> DynamicArray:
        """
        returns a dynamic array where each index contains a tuple of a key/value pair stored in the hash map
        """
        return_arr = DynamicArray()
        for i in range(self._capacity):
            current_hash_entry = self._buckets.get_at_index(i)
            if current_hash_entry is None or current_hash_entry.is_tombstone is True:
                pass
            else:
                return_arr.append((current_hash_entry.key, current_hash_entry.value))
        return return_arr

    def __iter__(self):
        """
        enables the hash map to iterate across itself
        """
        self._index = 0
        return self

    def __next__(self):
        """
        returns the next active item in the hash map based on the current location of the iterator
        """
        while True:
            try:
                hash_entry = self._buckets.get_at_index(self._index)
                if hash_entry is None or hash_entry.is_tombstone is True:
                    self._index += 1
                    continue
                else:
                    break
            except:
                raise StopIteration

        self._index = self._index + 1
        return hash_entry
