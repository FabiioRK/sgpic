import VMasker from "vanilla-masker";

function applyPhoneMask(input) {
    VMasker(input).maskPattern("(99) 99999-9999");
}

function applyPostalCodeMask(input) {
    VMasker(input).maskPattern("99999-999");
}

function applyCpfMask(input) {
    VMasker(input).maskPattern("999.999.999-99");
}

function isValidCpf(cpf) {
    cpf = cpf.replace(/\D/g, "");

    if (cpf.length !== 11 || /^(\d)\1{10}$/.test(cpf)) {
        return false;
    }

    const calcDigit = (base) => {
        let total = 0;
        for (let i = 0; i < base; i++) {
            total += parseInt(cpf[i]) * (base + 1 - i);
        }
        const rest = total % 11;
        return rest < 2 ? 0 : 11 - rest;
    };

    const digit1 = calcDigit(9);
    const digit2 = calcDigit(10);

    return parseInt(cpf[9]) === digit1 && parseInt(cpf[10]) === digit2;
}

function validateCpf(input) {
    const errorMessage = "CPF inválido";

    input.addEventListener("blur", () => {
        const value = input.value.trim();
        const parent = input.closest(".form-group") || input.parentNode;

        parent.querySelectorAll(".cpf-error-message").forEach((el) => el.remove());

        if (value && !isValidCpf(value)) {
            const error = document.createElement("div");
            error.classList.add("cpf-error-message", "text-danger", "small");
            error.textContent = errorMessage;
            parent.appendChild(error);
        }
    });
}

function validateEmail(input) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const errorMessage = "E-mail inválido";

    input.addEventListener("blur", () => {
        const value = input.value.trim();
        const parent = input.closest(".form-group") || input.parentNode;

        parent.querySelectorAll(".email-error-message").forEach((el) => el.remove());

        if (value && !emailRegex.test(value)) {
            const error = document.createElement("div");
            error.classList.add("email-error-message", "text-danger", "small");
            error.textContent = errorMessage;
            parent.appendChild(error);
        }
    });
}

export function applyMasks() {
    document.querySelectorAll("[data-mask='phone']").forEach((input) => {
        applyPhoneMask(input);
        input.addEventListener("input", () => applyPhoneMask(input));
    });

    document.querySelectorAll("[data-mask='postal_code']").forEach((input) => {
        applyPostalCodeMask(input);
        input.addEventListener("input", () => applyPostalCodeMask(input));
    });

    document.querySelectorAll("[data-mask='cpf']").forEach((input) => {
        applyCpfMask(input);
        validateCpf(input);
        input.addEventListener("input", () => applyCpfMask(input));
    });

    document.querySelectorAll("[data-mask='email']").forEach((input) => {
        validateEmail(input);
    });
}

["turbo:load", "turbo:render"].forEach((event) => {
    document.addEventListener(event, applyMasks);
});
