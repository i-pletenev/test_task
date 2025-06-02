# Task 2. Docker-образ

Docker-образ, содержащий программы:

- samtools
- htslib
- libdeflate
- bcftools
- vcftools

Все программы скомпилированы из исходного кода и установлены в `/soft`.

## Сборка образа

```bash
git clone https://github.com/i-pletenev/test_task.git
cd test_task
docker build -t bio-soft:latest .
```

## Запуск образа в интерактивном режиме

```bash
docker run --rm -it bio-soft:latest bash
```
