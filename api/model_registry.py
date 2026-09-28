from dataclasses import dataclass
import os


@dataclass(frozen=True)
class ModelDefinition:
    capability: str
    model_id: str
    version: str
    display_name: str
    status: str
    expected_class_count: int | None = None
    model_path_env: str | None = None
    classes_path_env: str | None = None
    fallback_model_path: str | None = None
    fallback_classes_path: str | None = None


MODEL_REGISTRY: dict[str, ModelDefinition] = {
    "disease": ModelDefinition(
        capability="disease",
        model_id="plant-disease-mobilenetv3",
        version="plantvillage-mobilenetv3-38-class",
        display_name="Plant Disease MobileNetV3",
        status="available",
        expected_class_count=38,
        model_path_env="PLANTCARE_MODEL_PATH",
        classes_path_env="PLANTCARE_CLASSES_PATH",
        fallback_model_path="artifacts/plant_disease_mobilenetv3.pth",
        fallback_classes_path="artifacts/class_names.txt",
    ),
    "pest": ModelDefinition(
        capability="pest",
        model_id="plant-pest-model",
        version="planned",
        display_name="Plant Pest Detection",
        status="planned",
    ),
    "nutrient": ModelDefinition(
        capability="nutrient",
        model_id="plant-nutrient-model",
        version="planned",
        display_name="Plant Nutrient Deficiency Detection",
        status="planned",
    ),
    "environment": ModelDefinition(
        capability="plant-stress-model",
        model_id="plant-stress-model",
        version="planned",
        display_name="Environmental Stress Detection",
        status="planned",
    ),
}


def get_model_definition(capability: str) -> ModelDefinition:
    normalized = capability.strip().lower()
    try:
        return MODEL_REGISTRY[normalized]
    except KeyError as exc:
        supported = ", ".join(sorted(MODEL_REGISTRY))
        raise ValueError(
            f"Unsupported PlantCare capability '{capability}'. "
            f"Supported capabilities: {supported}."
        ) from exc


def model_summary() -> list[dict[str, object]]:
    return [
        {
            "capability": definition.capability,
            "model_id": definition.model_id,
            "version": definition.version,
            "display_name": definition.display_name,
            "status": definition.status,
            "expected_class_count": definition.expected_class_count,
        }
        for definition in MODEL_REGISTRY.values()
    ]


def resolve_artifact_paths(definition: ModelDefinition) -> tuple[str, str]:
    if not definition.model_path_env or not definition.classes_path_env:
        raise RuntimeError(
            f"Capability '{definition.capability}' does not have an active model."
        )

    model_path = os.getenv(
        definition.model_path_env,
        definition.fallback_model_path or "",
    )
    classes_path = os.getenv(
        definition.classes_path_env,
        definition.fallback_classes_path or "",
    )
    return model_path, classes_path
