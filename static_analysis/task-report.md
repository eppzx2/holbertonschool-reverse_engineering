# Reverse Engineering Hesabatı — Holberton School

**Cohort 1104 | Elmir**

---

## Task 0 — String Analizi

Statik linklənmiş, strip olunmamış ELF binary idi, ona görə `strings` və `nm` kifayət etdi.

```bash
strings target-binary | grep -iE "flag|check"
nm target-binary | grep check_flag
```

`check_flag` funksiyası flag-ı stack üzərində bayt-bayt qurub `strcmp` ilə `argv[1]`-lə müqayisə edirdi. Disassembly-də bu baytları oxumaq kifayət etdi.

**Flag:** `HOLB{Reverse_Engineering_is_Fun}`

---

## Task 1 — Öz Şifrələmə Alqoritmi

Bu dəfə sadə `strcmp` yox, custom XOR+ADD şifrəsi var idi:

```
output[i] = (input[i] XOR key[i % 11]) + key[(i+1) % 11]   (mod 256)
```

`key` = `"mysecretkey"` (`.data`-da açıq mətn kimi hardcoded). Şifrələnmiş flag isə hex sətir kimi `.rodata`-da saxlanılırdı.

Formula tərsə çevrilib (`input = (output - key[i+1]) XOR key[i]`), Python-da hesablanıb və nəticə orijinal hex ilə **bit-bit yoxlanılıb** (forward-encrypt edib müqayisə etdim).

**Flag:** `Holberton{implementing_decrypt_function_on_your_own_is_done!}`

**Tapıntı:** hardcoded açar (`mysecretkey`) və özünəməxsus (öz-yazılmış) şifrələmə — real təhlükəsizlik təmin etmir, çünki alqoritm assembly-dən tam bərpa oluna bilir.

---

## Task 2 — Yavaş Alqoritmin Optimallaşdırılması

Burada RSA-vari modular exponentiation var idi, amma **naiv** şəkildə yazılmışdı:

```c
result = 1;
for (i = 0; i < exponent; i++)
    result = mulmod(result, base, mod);   // O(n) — hər addımda tam vuruş
```

`.data`-dan çıxardığım dəyərlər:
- `exponent` = 281,474,976,710,655
- `modulus`  = 1,152,921,504,606,846,971

Bu tempo ilə **~281 trilyon** dövr lazım idi — praktikada mümkünsüz (günlər/həftələr).

**Optimallaşdırma:** kvadrata-alma metodu (square-and-multiply, Python-un daxili `pow(base, exp, mod)` funksiyası) — eyni nəticəni cəmi **~48 addımda** verir.

```python
key = pow(2, exponent, modulus)
flag_word = encrypted_word ^ key
```

**Nəticə:** 281,474,976,710,655 əməliyyatdan → 48 əməliyyata (~5.9 trilyon dəfə sürətli).

**Flag:** `Holberton{optimizingslowcode_isannoying_but_is_a_must}`

---

## Ümumi Nəticə

| Task | Zəiflik | Üsul |
|---|---|---|
| 0 | Hardcoded flag + zəif müqayisə | `strings` + disassembly |
| 1 | Hardcoded açar, öz şifrəsi | Alqoritmi tərsə çevirmək |
| 2 | Naiv (yavaş) alqoritm | Riyazi optimallaşdırma |

Üç tapşırıq da onu göstərdi ki, statik analiz təkcə `strings`-lə bitmir — assembly səviyyəsində məntiqi anlamaq, riyazi tərs çevirmək və alqoritmik mürəkkəbliyi qiymətləndirmək tələb olunur.
