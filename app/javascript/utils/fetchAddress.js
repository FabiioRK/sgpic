function fetchAddress(cep, scope) {
    fetch(`https://viacep.com.br/ws/${cep}/json/`)
        .then((response) => {
            if (!response.ok) {
                throw new Error("Erro ao conectar com a API de CEP.");
            }
            return response.json();
        })
        .then((data) => {
            if (!data.erro) {
                const baseName = scope;
                if (!baseName) {
                    console.warn("Atributo data-scope não contém o caminho base esperado.");
                    return;
                }

                const addressFields = {
                    street: document.querySelector(`input[name="${baseName}[street]"]`),
                    district: document.querySelector(`input[name="${baseName}[district]"]`),
                    city: document.querySelector(`input[name="${baseName}[city]"]`),
                    state: document.querySelector(`input[name="${baseName}[state]"]`),
                };

                console.log("Campos de endereço localizados:", addressFields);

                if (Object.values(addressFields).some((field) => field === null)) {
                    console.warn("Alguns campos de endereço não foram encontrados. Verifique os atributos name.");
                    return;
                }

                if (addressFields.street) addressFields.street.value = data.logradouro || '';
                if (addressFields.district) addressFields.district.value = data.bairro || '';
                if (addressFields.city) addressFields.city.value = data.localidade || '';
                if (addressFields.state) addressFields.state.value = data.uf || '';
            } else {
                alert("CEP não encontrado.");
            }
        })
        .catch((error) => {
            console.error("Erro ao buscar o endereço:", error);
        });
}


export function initializeAddressAutocomplete() {
    document.querySelectorAll("[data-autocomplete='cep']").forEach((cepInput) => {
        cepInput.addEventListener("blur", (event) => {
            const cep = event.target.value.replace(/\D/g, "");
            console.log("CEP capturado:", cep);

            if (cep.length === 8) {
                const scope = event.target.getAttribute("data-scope");
                if (scope) {
                    console.log("Escopo identificado:", scope);

                    fetchAddress(cep, scope);
                } else {
                    console.warn("Atributo data-scope ausente ou não encontrado no campo de CEP.");
                }
            } else {
                alert("CEP inválido. Certifique-se de inserir 8 números.");
            }
        });
    });
}

["turbo:load", "turbo:render"].forEach((event) => {
    document.addEventListener(event, initializeAddressAutocomplete);
});