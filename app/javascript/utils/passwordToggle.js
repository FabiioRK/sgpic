export function togglePasswordVisibility(inputClassName) {
    const input = document.querySelector(`.${inputClassName}`);
    if (!input) {
        console.warn(`Campo com a classe '${inputClassName}' não encontrado.`);
        return;
    }

    const buttonIcon = input.nextElementSibling.querySelector("i");
    if (input.type === "password") {
        input.type = "text";
        buttonIcon.classList.remove("bi-eye");
        buttonIcon.classList.add("bi-eye-slash");
    } else {
        input.type = "password";
        buttonIcon.classList.remove("bi-eye-slash");
        buttonIcon.classList.add("bi-eye");
    }
}