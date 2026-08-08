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

# Task 3 — Binary Reverse Engineering
 
## Nə verilmişdi
`main3` adlı ELF binary faylı istifadəçidən flag daxil etməyi istəyir və onu `check_flag` funksiyası vasitəsilə yoxlayır.
 
## Kod nə edir
`objdump` ilə açdıqda `check_flag` funksiyasının içində 60 elementli hardcode olunmuş `target[]` massivi görünür (gözlənilən nəticələr). Hər simvol üçün belə bir yoxlama aparılır:
 
1. Daxiletmənin `i`-ci simvolu (`c`) götürülür
2. Əgər `i` **tək** (odd) — `c * 0x13C`, sonra `XOR 0x9E0`
3. Əgər `i` **cüt** (even) — `c * -46`, sonra `XOR -368`
4. Nəticə `& 0xFF` ilə bir bayta endirilir və `target[i]`-ə bərabər olmalıdır
```
if i % 2 == 1: val = (c * 0x13C) ^ 0x9E0
else:          val = (c * -46)  ^ -368
val &= 0xFF   →   target[i] ilə müqayisə
```
 
## Necə həll etdim
- Vurma əməliyyatı **tərsə çevrilə bilməyən** (non-invertible) olduğu üçün hər mövqe üçün 0–255 aralığında bütün mümkün simvolları sınadım (brute-force).
- **Cüt** mövqelərdə demək olar ki, hər zaman **yeganə** düzgün simvol tapıldı.
- **Tək** mövqelərdə isə tapşırıqda deyilən "collision" özünü göstərdi — hər dəfə 2 fərqli oxuna bilən variant çıxdı (məs. `{` və ya `;`, `o` və ya `/`). Bunlardan mənalı, oxunaqlı olanı (hərf/altxətt) seçdim.
- Alınan mətni yığıb formatla (`Holberton{...}`) uzlaşdırdım və son simvol kimi "?" (simvol) `}`-dan əvvəl gəldi.
- Nəhayət, flag-i birbaşa binary-yə daxil edib **"Correct flag!"** cavabı alaraq təsdiqlədim.
## Nəticə
 
```
Holberton{Do_you_think_now_you_are_a_master_of_obfuscation?}
```
 
---

# Task 4 — Assembly Reverse Engineering
 
## Nə verilmişdi
`task4.asm` faylında `_start` funksiyası istifadəçidən daxiletmə alır və onu `obfuscated_flag` adlı, 28 elementdən ibarət şifrələnmiş massivlə müqayisə edir.
 
## Kod nə edir
Hər simvol üçün dövr (`check_loop`) aşağıdakı əməliyyatları icra edir:
 
1. `obfuscated_flag[i]` dəyərini götürür
2. `XOR 0x55` edir
3. `7` çıxır
4. `3`-ə bölür (`idiv`)
Yəni deşifrə düsturu belədir:
 
```
char = ((obfuscated_flag[i] XOR 0x55) - 7) / 3
```
 
## Necə həll etdim
- Massivdəki 28 dəyərin hər birinə yuxarıdakı düsturu tətbiq etdim.
- Bölmədən qalan (remainder) hər dəfə **0** çıxdı — bu, düsturun düzgün olduğunu təsdiqləyən əsas işarə idi (əks halda mənasız simvollar alınardı).
- Nəticədə oxunaqlı, məntiqli bir mətn ortaya çıxdı.
*Qeyd:* Assembly kodunda `mov edx, ebx` sətri texniki olaraq ondan sonra gələn `cdq` təlimatı tərəfindən üzərinə yazılır (bu, real icra zamanı "ölü kod" effekti yaradır). Amma massivdəki rəqəmlərin özü düzgün deşifrə düsturunu aydın göstərdiyi üçün, bu, çox güman ki, tələbəni diqqətli oxumağa təşviq edən qəsdən qoyulmuş bir detaldır.
 
## Nəticə
 
```
Holberton{back_to_assembly!}
```
 
