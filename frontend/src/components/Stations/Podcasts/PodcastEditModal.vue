<template>
    <modal-form
        ref="$modal"
        :loading="loading"
        :title="langTitle"
        :error="error"
        :disable-save-button="v$.$invalid"
        @submit="doSubmit"
        @hidden="clearContents"
    >
        <tabs>
            <podcast-form-basic-info
                :form="form"
                :categories-options="categoriesOptions"
                :language-options="languageOptions"
            />

            <podcast-common-artwork
                v-model="form.artwork_file"
                :artwork-src="record.links.art"
                :new-art-url="newArtUrl"
            />
        </tabs>
    </modal-form>
</template>

<script setup lang="ts">
import PodcastFormBasicInfo from './PodcastForm/BasicInfo.vue';
import PodcastCommonArtwork from './Common/Artwork.vue';
import mergeExisting from "~/functions/mergeExisting";
import {baseEditModalProps, ModalFormTemplateRef, useBaseEditModal} from "~/functions/useBaseEditModal";
import {computed, ref} from "vue";
import {useResettableRef} from "~/functions/useResettableRef";
import {useTranslate} from "~/vendor/gettext";
import ModalForm from "~/components/Common/ModalForm.vue";
import Tabs from "~/components/Common/Tabs.vue";
import {map} from "lodash";

const props = defineProps({
    ...baseEditModalProps,
    languageOptions: {
        type: Object,
        required: true
    },
    categoriesOptions: {
        type: Object,
        required: true
    },
    newArtUrl: {
        type: String,
        required: true
    }
});

const emit = defineEmits(['relist']);

const $modal = ref<ModalFormTemplateRef>(null);

const {record, reset} = useResettableRef({
    has_custom_art: false,
    art: null,
    links: {
        art: null
    }
});

const {
    loading,
    error,
    isEditMode,
    form,
    v$,
    clearContents,
    create,
    edit,
    doSubmit,
    close
} = useBaseEditModal(
    props,
    emit,
    $modal,
    {},
    {
        artwork_file: null
    },
    {
        resetForm: (originalResetForm) => {
            originalResetForm();
            reset();
        },
        populateForm: (data, formRef) => {
            data.categories = map(
                data.categories,
                (row) => row.category
            );

            record.value = data;
            formRef.value = mergeExisting(formRef.value, data);
        },
    },
);

const {$gettext} = useTranslate();

const langTitle = computed(() => {
    return isEditMode.value
        ? $gettext('Edit Podcast')
        : $gettext('Add Podcast');
});

defineExpose({
    create,
    edit,
    close
});
</script>
