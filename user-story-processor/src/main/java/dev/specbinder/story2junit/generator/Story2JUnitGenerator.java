package dev.specbinder.story2junit.generator;

import com.squareup.javapoet.JavaFile;
import dev.specbinder.story2junit.Story2JUnit;

import javax.annotation.processing.*;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;
import javax.tools.JavaFileObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;

/**
 * APT processor that generates JUnit test subclasses based on the Story2JUnit annotation.
 */
@SupportedAnnotationTypes("dev.specbinder.story2junit.Story2JUnit")
@SupportedSourceVersion(SourceVersion.RELEASE_21)
//@AutoService(Processor.class)
public class Story2JUnitGenerator extends AbstractProcessor {

    /**
     * Constructor
     */
    Story2JUnitGenerator() {
    }

    @Override
    public synchronized void init(ProcessingEnvironment processingEnv) {}

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {

        message("Running " + this.getClass().getSimpleName() + " processor");

        for (TypeElement annotation : annotations) {

            String annotationName = annotation.getQualifiedName().toString();
            if (!annotationName.equals(Story2JUnit.class.getName())) {
                /**
                 * not our target annotation
                 */
                continue;
            }

            Set<? extends Element> annotatedElements = roundEnv.getElementsAnnotatedWith(annotation);
            for (Element annotatedElement : annotatedElements) {

                message("annotatedElement.simpleName = " + annotatedElement.getSimpleName());

                Story2JUnit targetAnnotation = annotatedElement.getAnnotation(Story2JUnit.class);
                if (targetAnnotation == null) {
                    continue; // shouldn't really happen
                }

                TypeElement annotatedClass = (TypeElement) annotatedElement;

                TestSubclassGenerator subclassGenerator = new TestSubclassGenerator(processingEnv, processingEnv);

//                Set<? extends Element> rootElements = roundEnv.getRootElements();
//                Map<String, String> options = processingEnv.getOptions();

                JavaFile javaFile;
                try {
                    javaFile = subclassGenerator.createTestSubclass(annotatedElement, targetAnnotation);
                } catch (IOException e) {
                    throw new RuntimeException("An error occurred while processing annotated element - " + annotatedClass.getSimpleName(), e);
                }

                final String suffixForGeneratedClass = "Scenarios";
                Filer filer = processingEnv.getFiler();
                String subclassFullyQualifiedName = annotatedClass.getQualifiedName() + suffixForGeneratedClass;

                JavaFileObject subclassFile = null;
                try {
                    subclassFile = filer.createSourceFile(subclassFullyQualifiedName);
                } catch (IOException e) {
                    throw new RuntimeException("An error occurred while attempting to create subclass file with a name - '" + subclassFullyQualifiedName + "'", e);
                }

                try (PrintWriter out = new PrintWriter(subclassFile.openWriter())) {
                    javaFile.writeTo(out);
                } catch (IOException e) {
                    throw new RuntimeException("An error occurred while attempting to write Java file named - '" + subclassFile.getName() + "'", e);
                }

            }
        }

        return true;
    }

    private void message(String message) {

        processingEnv.getMessager().printMessage(Diagnostic.Kind.MANDATORY_WARNING, message);
    }

    private void messageError(String message) {

        processingEnv.getMessager().printMessage(Diagnostic.Kind.ERROR, message);
    }
}